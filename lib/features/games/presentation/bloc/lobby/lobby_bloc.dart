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
import 'package:fantavacanze_official/features/games/domain/usecases/kill_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_player_name_in_lobby.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/remove_game_player_from_lobby.dart';

part 'lobby_event.dart';
part 'lobby_state.dart';

class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  // =====================================================================
  // PROPERTIES
  // =====================================================================
  final CreateGameSession _createGameSession;
  final JoinGameSession _joinGameSession;
  final LeaveGameSession _leaveGameSession;
  final StreamGameSession _streamGameSession;
  final StreamLobbyPlayers _streamLobbyPlayers;
  final UpdateGameState _updateGameState;
  final AppUserCubit _appUserCubit;
  final KillGameSession _killGameSession;
  final UpdateGamePlayerNameInLobby _updateGamePlayerNameInLobby;
  final RemoveGamePlayerFromLobby _removeGamePlayerFromLobby;

  StreamSubscription<dynamic>? _sessionSubscription;
  StreamSubscription<dynamic>? _playersSubscription;

  // =====================================================================
  // CONSTRUCTOR
  // =====================================================================
  LobbyBloc({
    required CreateGameSession createGameSession,
    required JoinGameSession joinGameSession,
    required LeaveGameSession leaveGameSession,
    required StreamGameSession streamGameSession,
    required StreamLobbyPlayers streamLobbyPlayers,
    required UpdateGameState updateGameState,
    required AppUserCubit appUserCubit,
    required KillGameSession killGameSession,
    required UpdateGamePlayerNameInLobby updateGamePlayerNameInLobby,
    required RemoveGamePlayerFromLobby removeGamePlayerFromLobby,
  })  : _createGameSession = createGameSession,
        _joinGameSession = joinGameSession,
        _leaveGameSession = leaveGameSession,
        _streamGameSession = streamGameSession,
        _streamLobbyPlayers = streamLobbyPlayers,
        _updateGameState = updateGameState,
        _appUserCubit = appUserCubit,
        _killGameSession = killGameSession,
        _updateGamePlayerNameInLobby = updateGamePlayerNameInLobby,
        _removeGamePlayerFromLobby = removeGamePlayerFromLobby,
        super(LobbyInitial()) {
    on<CreateSessionRequested>(_onCreateSessionRequested);
    on<JoinSessionRequested>(_onJoinSessionRequested);
    on<LeaveSessionRequested>(_onLeaveSessionRequested);
    on<StartGameRequested>(_onStartGameRequested);
    on<KillSessionRequested>(_onKillSessionRequested);
    on<EditPlayerNameRequested>(_onEditPlayerNameRequested);
    on<RemovePlayerFromLobbyRequested>(_onRemovePlayerFromLobbyRequested);
    on<_SessionUpdated>(_onSessionUpdated);
    on<_PlayersUpdated>(_onPlayersUpdated);
    on<_StreamErrorOccurred>(_onStreamErrorOccurred);
  }

  // =====================================================================
  // GETTERS
  // =====================================================================
  auth_user.User? get _currentUser {
    final userState = _appUserCubit.state;
    if (userState is AppUserIsLoggedIn) {
      return userState.user;
    }
    return null;
  }

  // =====================================================================
  // EVENT HANDLERS
  // =====================================================================

  // ------------------ ON CREATE SESSION REQUESTED ------------------ //
  Future<void> _onCreateSessionRequested(
    CreateSessionRequested event,
    Emitter<LobbyState> emit,
  ) async {
    emit(const LobbyLoading(message: 'Creazione sessione...'));
    final user = _currentUser;
    if (user == null) {
      emit(const LobbyError('Utente non autenticato.'));
      return;
    }

    final result = await _createGameSession(
      CreateGameSessionParams(
        adminId: user.id,
        gameType: event.gameType,
        userName: _currentUser!.name,
      ),
    );

    result.fold(
      (failure) => emit(LobbyError(failure.message)),
      (session) {
        _initStreams(session.id, emit);
        emit(LobbySessionActive(session: session, players: const []));
      },
    );
  }

  // ------------------ ON JOIN SESSION REQUESTED ------------------ //
  Future<void> _onJoinSessionRequested(
    JoinSessionRequested event,
    Emitter<LobbyState> emit,
  ) async {
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
    ));

    result.fold(
      (failure) => emit(LobbyError(failure.message)),
      (session) {
        _initStreams(session.id, emit);
        emit(LobbySessionActive(session: session, players: const []));
      },
    );
  }

  // ------------------ ON LEAVE SESSION REQUESTED ------------------ //
  Future<void> _onLeaveSessionRequested(
    LeaveSessionRequested event,
    Emitter<LobbyState> emit,
  ) async {
    final user = _currentUser;
    if (user == null) {
      emit(const LobbyError('Utente non autenticato.'));
      return;
    }

    final result = await _leaveGameSession(LeaveGameSessionParams(
      sessionId: event.sessionId,
      userId: user.id,
    ));

    result.fold(
      (failure) {
        if (state is LobbySessionActive) {
          emit((state as LobbySessionActive)
              .copyWith(isLoadingNextAction: false));
        } else {
          emit(LobbyError(failure.message));
        }
      },
      (sessionWasKilled) {
        _cancelSubscriptions();
        emit(LobbyInitial());
      },
    );
  }

  // ------------------ ON START GAME REQUESTED ------------------ //
  Future<void> _onStartGameRequested(
    StartGameRequested event,
    Emitter<LobbyState> emit,
  ) async {
    if (state is LobbySessionActive) {
      final currentLobbyState = state as LobbySessionActive;
      final user = _currentUser;

      if (user == null || user.id != currentLobbyState.session.adminId) {
        emit(LobbyError("Solo l'admin può iniziare la partita."));

        emit(currentLobbyState.copyWith());

        return;
      }

      if (currentLobbyState.players.isEmpty) {
        emit(LobbyError(
            "Non ci sono giocatori nella lobby per iniziare la partita."));

        emit(currentLobbyState.copyWith(isLoadingNextAction: false));
        return;
      }

      // ---------- UNCOMMENTE IF YOU WANT TO ENFORCE MINIMUM PLAYERS ---------
      // if (currentLobbyState.players.length < 2 &&
      //     currentLobbyState.session.gameType != GameType.wordBomb) {
      //   // WordBomb can be played solo
      //   emit(LobbyError(
      //       "Sono necessari almeno 2 giocatori per iniziare questa partita."));
      //   emit(currentLobbyState.copyWith(isLoadingNextAction: false));
      //   return;
      // }

      emit(currentLobbyState.copyWith(isLoadingNextAction: true));

      final String firstPlayerUserId = currentLobbyState.players.first.userId;

      final result = await _updateGameState(
        UpdateGameStateParams(
          sessionId: event.sessionId,
          status: GameStatus.inProgress,
          currentTurnUserId: firstPlayerUserId,
        ),
      );

      result.fold((failure) {
        emit(LobbyError(failure.message));
        emit(
          currentLobbyState.copyWith(
            isLoadingNextAction: false,
          ),
        );
      }, (_) {
        // Session stream will update the state to inProgress.
      });
    }
  }

  // ------------------ ON KILL SESSION REQUESTED ------------------ //
  Future<void> _onKillSessionRequested(
    KillSessionRequested event,
    Emitter<LobbyState> emit,
  ) async {
    final user = _currentUser;

    if (user == null) {
      emit(const LobbyError('Utente non autenticato.'));
      return;
    }

    if (state is LobbySessionActive) {
      final currentLobbyState = state as LobbySessionActive;

      if (user.id != currentLobbyState.session.adminId) {
        emit(LobbyError("Solo l'admin può terminare la sessione."));
        return;
      }

      emit(currentLobbyState.copyWith(isLoadingNextAction: true));
    } else {
      emit(const LobbyLoading(message: "Terminazione sessione..."));
    }

    final result = await _killGameSession(event.sessionId);

    result.fold(
      (failure) {
        if (state is LobbySessionActive) {
          emit(
            (state as LobbySessionActive).copyWith(isLoadingNextAction: false),
          );
        } else {
          emit(LobbyError(failure.message));
        }
      },
      (_) {
        _cancelSubscriptions();
        emit(LobbyInitial());
      },
    );
  }

  // ------------------ ON EDIT PLAYER NAME REQUESTED ------------------ //
  Future<void> _onEditPlayerNameRequested(
    EditPlayerNameRequested event,
    Emitter<LobbyState> emit,
  ) async {
    final user = _currentUser;
    if (user == null ||
        (state is! LobbySessionActive ||
            (state as LobbySessionActive).session.adminId != user.id)) {
      emit(const LobbyError("Solo l'admin può modificare i nomi."));
      return;
    }

    if (state is LobbySessionActive) {
      // Optionally show loading for this specific action on the player item
      // For now, relying on stream to update UI
      final result = await _updateGamePlayerNameInLobby(
        UpdateGamePlayerNameInLobbyParams(
          playerId: event.playerId,
          newName: event.newName,
          sessionId: event.sessionId,
        ),
      );
      result.fold(
        (failure) => emit(LobbyError(failure.message)),
        (_) {
          // Name updated, stream should refresh the player list
          // No explicit state change needed here if streams are working correctly
        },
      );
    }
  }

  // ------------------ ON REMOVE PLAYER FROM LOBBY REQUESTED ------------------ //
  Future<void> _onRemovePlayerFromLobbyRequested(
    RemovePlayerFromLobbyRequested event,
    Emitter<LobbyState> emit,
  ) async {
    final user = _currentUser;

    if (user == null) {
      emit(const LobbyError("Utente non autenticato."));
      return;
    }

    if (state is! LobbySessionActive) {
      emit(const LobbyError("Stato della lobby non valido."));
      return;
    }

    final currentLobbyState = state as LobbySessionActive;
    if (currentLobbyState.session.adminId != user.id) {
      emit(const LobbyError("Solo l'admin può rimuovere giocatori."));
      return;
    }

    GamePlayer? playerToRemove;
    try {
      playerToRemove = currentLobbyState.players.firstWhere(
        (p) => p.id == event.playerId,
      );
    } catch (e) {
      emit(LobbyError(
          "Giocatore da rimuovere non trovato nella lobby attuale."));
      return;
    }

    if (playerToRemove.userId == user.id) {
      emit(LobbyError(
          "L'admin non può auto-rimuoversi da qui. Usa 'Esci dalla Lobby'."));
      return;
    }

    final result = await _removeGamePlayerFromLobby(
      RemoveGamePlayerFromLobbyParams(
        playerId: event.playerId,
        sessionId: event.sessionId,
      ),
    );
    result.fold(
      (failure) {
        emit(LobbyError(failure.message));
      },
      (_) {
        // Player removed, stream should refresh the player list
      },
    );
  }

  // =====================================================================
  // INTERNAL EVENT HANDLERS / STREAM UPDATERS
  // =====================================================================

  // ------------------ ON SESSION UPDATED ------------------ //
  void _onSessionUpdated(_SessionUpdated event, Emitter<LobbyState> emit) {
    if (state is LobbySessionActive) {
      final current = state as LobbySessionActive;
      if (event.session.id != current.session.id ||
          event.session.status == GameStatus.finished) {
        _cancelSubscriptions();
        emit(LobbyInitial());
        return;
      }

      emit(
        current.copyWith(session: event.session, isLoadingNextAction: false),
      );
    } else if (state is LobbyInitial || state is LobbyLoading) {
      emit(LobbySessionActive(session: event.session, players: const []));
    }
  }

  // ------------------ ON PLAYERS UPDATED ------------------ //
  void _onPlayersUpdated(_PlayersUpdated event, Emitter<LobbyState> emit) {
    if (state is LobbySessionActive) {
      final currentLobbyState = state as LobbySessionActive;
      final currentUser = _currentUser;

      if (currentUser != null) {
        // Check if the current user is still in the updated list of players
        final currentPlayerInList = event.players.any(
          (player) => player.userId == currentUser.id,
        );

        if (!currentPlayerInList &&
            currentLobbyState.session.adminId != currentUser.id) {
          // Current user is no longer in the player list and is not the admin
          // (admin leaving is handled by LeaveSessionRequested or KillSessionRequested)
          // This means they were likely removed by the admin.
          _cancelSubscriptions();
          emit(LobbyInitial()); // Or a specific "KickedFromLobby" state
          // Optionally, emit a specific message/event to show a snackbar like "Sei stato rimosso dalla lobby."
          // For now, LobbyInitial will take them out of the GameHostPage.
          return;
        }
      }
      emit(currentLobbyState.copyWith(players: event.players));
    } else if (state is LobbyInitial ||
        state is LobbyLoading && _sessionSubscription != null) {
      // Assume _SessionUpdated sets up LobbySessionActive first.
      // This part should ideally not be hit if _SessionUpdated correctly sets state.
    }
  }

  // ------------------ ON STREAM ERROR OCCURRED ------------------ //
  void _onStreamErrorOccurred(
    _StreamErrorOccurred event,
    Emitter<LobbyState> emit,
  ) {
    _cancelSubscriptions();
    emit(LobbyError(event.message));
  }

  // =====================================================================
  // UTILITY METHODS
  // =====================================================================

  // ------------------ INIT STREAMS ------------------ //
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

  // ------------------ CANCEL SUBSCRIPTIONS ------------------ //
  void _cancelSubscriptions() {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _playersSubscription?.cancel();
    _playersSubscription = null;
  }

  // =====================================================================
  // LIFECYCLE METHODS
  // =====================================================================

  // ------------------ CLOSE ------------------ //
  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
