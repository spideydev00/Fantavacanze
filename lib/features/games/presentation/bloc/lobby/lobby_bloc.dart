import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart'
    as auth_user;
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/create_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/join_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/leave_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_lobby_players.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_state.dart';

part 'lobby_event.dart';
part 'lobby_state.dart';

class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  final CreateGameSession _createGameSession;
  final JoinGameSession _joinGameSession;
  final LeaveGameSession _leaveGameSession;
  final StreamGameSession _streamGameSession;
  final StreamLobbyPlayers _streamLobbyPlayers;
  final UpdateGameState _updateGameState;
  final AppUserCubit _appUserCubit;

  StreamSubscription<dynamic>? _sessionSubscription;
  StreamSubscription<dynamic>? _playersSubscription;

  LobbyBloc({
    required CreateGameSession createGameSession,
    required JoinGameSession joinGameSession,
    required LeaveGameSession leaveGameSession,
    required StreamGameSession streamGameSession,
    required StreamLobbyPlayers streamLobbyPlayers,
    required UpdateGameState updateGameState,
    required AppUserCubit appUserCubit,
  })  : _createGameSession = createGameSession,
        _joinGameSession = joinGameSession,
        _leaveGameSession = leaveGameSession,
        _streamGameSession = streamGameSession,
        _streamLobbyPlayers = streamLobbyPlayers,
        _updateGameState = updateGameState,
        _appUserCubit = appUserCubit,
        super(LobbyInitial()) {
    on<CreateSessionRequested>(_onCreateSessionRequested);
    on<JoinSessionRequested>(_onJoinSessionRequested);
    on<LeaveSessionRequested>(_onLeaveSessionRequested);
    on<StartGameRequested>(_onStartGameRequested);
    on<_SessionUpdated>(_onSessionUpdated);
    on<_PlayersUpdated>(_onPlayersUpdated);
    on<_StreamErrorOccurred>(_onStreamErrorOccurred);
  }

  auth_user.User? get _currentUser {
    final userState = _appUserCubit.state;
    if (userState is AppUserIsLoggedIn) {
      return userState.user;
    }
    return null;
  }

  Future<void> _onCreateSessionRequested(
      CreateSessionRequested event, Emitter<LobbyState> emit) async {
    emit(const LobbyLoading(message: 'Creazione sessione...'));
    final user = _currentUser;
    if (user == null) {
      emit(const LobbyError('Utente non autenticato.'));
      return;
    }

    final result = await _createGameSession(
        CreateGameSessionParams(adminId: user.id, gameType: event.gameType));

    result.fold(
      (failure) => emit(LobbyError(failure.message)),
      (session) {
        _initStreams(session.id, emit);
        // Emit initial active state, streams will update it
        emit(LobbySessionActive(session: session, players: const []));
      },
    );
  }

  Future<void> _onJoinSessionRequested(
      JoinSessionRequested event, Emitter<LobbyState> emit) async {
    emit(const LobbyLoading(message: 'Accesso alla sessione...'));
    final user = _currentUser;
    if (user == null) {
      emit(const LobbyError('Utente non autenticato.'));
      return;
    }

    final result = await _joinGameSession(JoinGameSessionParams(
      inviteCode: event.inviteCode,
      userId: user.id,
      userName: user.name,
      // userAvatarUrl: user.avatarUrl, // If you have avatar URL in User entity
    ));

    result.fold(
      (failure) => emit(LobbyError(failure.message)),
      (session) {
        _initStreams(session.id, emit);
        emit(LobbySessionActive(session: session, players: const []));
      },
    );
  }

  Future<void> _onLeaveSessionRequested(
      LeaveSessionRequested event, Emitter<LobbyState> emit) async {
    final user = _currentUser;
    if (user == null) {
      emit(const LobbyError('Utente non autenticato.'));
      return;
    }
    // No loading state change here, let streams handle UI update or navigation
    final result = await _leaveGameSession(LeaveGameSessionParams(
      sessionId: event.sessionId,
      userId: user.id,
    ));

    result.fold(
      (failure) {
        if (state is LobbySessionActive) {
          // Show error on current screen if possible, or rely on stream to clear session
          emit(LobbyError('Errore durante l\'uscita: ${failure.message}'));
          // Potentially re-emit LobbySessionActive if you want to show the error within the lobby
        } else {
          emit(LobbyError(failure.message));
        }
      },
      (_) {
        // Successfully left, streams should update. If no longer part of session,
        // _sessionSubscription might error or return empty, leading to LobbyInitial.
        // Or, explicitly emit LobbyInitial after cancelling streams.
        _cancelSubscriptions();
        emit(LobbyInitial());
      },
    );
  }

  Future<void> _onStartGameRequested(
      StartGameRequested event, Emitter<LobbyState> emit) async {
    if (state is LobbySessionActive) {
      final currentLobbyState = state as LobbySessionActive;
      final user = _currentUser;
      if (user == null || user.id != currentLobbyState.session.adminId) {
        emit(LobbyError("Solo l'admin può iniziare la partita."));
        // Re-emit current state to clear error after a delay or on next event
        emit(currentLobbyState.copyWith());
        return;
      }

      emit(currentLobbyState.copyWith(isLoadingNextAction: true));

      final result = await _updateGameState(UpdateGameStateParams(
        sessionId: event.sessionId,
        newGameState: {}, // Initial empty game state, or specific to game type
        status: GameStatus.inProgress,
      ));

      result.fold((failure) => emit(LobbyError(failure.message)),
          // Success: Session stream will update the state to inProgress.
          // LobbySessionActive will then be handled by GameHostPage to navigate.
          // No need to emit a new state here as the stream will do it.
          (_) {
        // The isLoadingNextAction will be cleared by the next _SessionUpdated event
      });
    }
  }

  void _initStreams(String sessionId, Emitter<LobbyState> emit) {
    _cancelSubscriptions();

    _sessionSubscription = _streamGameSession(sessionId).listen(
      (eitherSession) => eitherSession.fold(
        (failure) =>
            add(_StreamErrorOccurred('Errore sessione: ${failure.message}')),
        (session) => add(_SessionUpdated(session)),
      ),
      onError: (error) =>
          add(_StreamErrorOccurred('Errore stream sessione: $error')),
    );

    _playersSubscription = _streamLobbyPlayers(sessionId).listen(
      (eitherPlayers) => eitherPlayers.fold(
        (failure) =>
            add(_StreamErrorOccurred('Errore giocatori: ${failure.message}')),
        (players) => add(_PlayersUpdated(players)),
      ),
      onError: (error) =>
          add(_StreamErrorOccurred('Errore stream giocatori: $error')),
    );
  }

  void _onSessionUpdated(_SessionUpdated event, Emitter<LobbyState> emit) {
    if (state is LobbySessionActive) {
      final current = state as LobbySessionActive;
      // If session ID changes or status is finished, might indicate we should leave lobby
      if (event.session.id != current.session.id ||
          event.session.status == GameStatus.finished) {
        _cancelSubscriptions();
        emit(LobbyInitial());
        return;
      }
      emit(
          current.copyWith(session: event.session, isLoadingNextAction: false));
    } else if (state is LobbyInitial || state is LobbyLoading) {
      // This can happen if streams are initialized before LobbySessionActive is emitted
      // or if an error occurred and we are recovering.
      emit(LobbySessionActive(session: event.session, players: const []));
    }
    // If game becomes inProgress, GameHostPage will handle navigation.
    // This BLoC continues to provide session data.
  }

  void _onPlayersUpdated(_PlayersUpdated event, Emitter<LobbyState> emit) {
    if (state is LobbySessionActive) {
      final current = state as LobbySessionActive;
      emit(current.copyWith(players: event.players));
    } else if (state is LobbyInitial ||
        state is LobbyLoading && _sessionSubscription != null) {
      // This case is less likely if _SessionUpdated always fires first to establish LobbySessionActive
      // However, to be safe, if we have players but no session state yet, we might need to wait
      // or handle it based on whether a session object is available.
      // For now, assume _SessionUpdated sets up LobbySessionActive first.
    }
  }

  void _onStreamErrorOccurred(
      _StreamErrorOccurred event, Emitter<LobbyState> emit) {
    // Decide if error is fatal for the lobby
    _cancelSubscriptions(); // Stop listening on error
    emit(LobbyError(event.message));
    // Optionally, transition to LobbyInitial after showing error
    // Future.delayed(Duration(seconds:3), () => emit(LobbyInitial()));
  }

  void _cancelSubscriptions() {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _playersSubscription?.cancel();
    _playersSubscription = null;
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
