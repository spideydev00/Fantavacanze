import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart'
    as auth_user;
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/entities/never_have_i_ever_question.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/get_never_have_i_ever_cards.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_lobby_players.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_state.dart';

part 'never_have_i_ever_event.dart';
part 'never_have_i_ever_state.dart';

class NeverHaveIEverBloc
    extends Bloc<NeverHaveIEverEvent, NeverHaveIEverState> {
  // =====================================================================
  // PROPERTIES
  // =====================================================================
  final GetNeverHaveIEverCards _getNeverHaveIEverCards;
  final StreamGameSession _streamGameSession;
  final StreamLobbyPlayers _streamLobbyPlayers;
  final UpdateGameState _updateGameState;
  final AppUserCubit _appUserCubit;

  StreamSubscription<dynamic>? _sessionSubscription;
  StreamSubscription<dynamic>? _playersSubscription;

  List<NeverHaveIEverQuestion> _allQuestionsList = [];
  List<GamePlayer> _currentPlayersList = [];
  bool _isSinglePlayerLocalMode = false;

  /// Tiene traccia degli ID delle domande già usate (max 200)
  List<String> _askedQuestionIds = [];

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

  bool _isAdmin(GameSession? session) =>
      session != null && _currentUser?.id == session.adminId;

  // =====================================================================
  // CONSTRUCTOR
  // =====================================================================
  NeverHaveIEverBloc({
    required GetNeverHaveIEverCards getNeverHaveIEverCards,
    required StreamGameSession streamGameSession,
    required StreamLobbyPlayers streamLobbyPlayers,
    required UpdateGameState updateGameState,
    required AppUserCubit appUserCubit,
  })  : _getNeverHaveIEverCards = getNeverHaveIEverCards,
        _streamGameSession = streamGameSession,
        _streamLobbyPlayers = streamLobbyPlayers,
        _updateGameState = updateGameState,
        _appUserCubit = appUserCubit,
        super(NeverHaveIEverInitial()) {
    on<InitializeNeverHaveIEverGame>(_onInitializeNeverHaveIEverGame);
    on<NextQuestionRequested>(_onNextQuestionRequested);
    on<_NeverHaveIEverSessionUpdated>(_onSessionUpdated);
    on<_NeverHaveIEverPlayersUpdated>(_onPlayersUpdated);
    on<_NeverHaveIEverStreamErrorOccurred>(_onStreamErrorOccurred);
  }

  // =====================================================================
  // EVENT HANDLERS
  // =====================================================================

  Future<void> _onInitializeNeverHaveIEverGame(
    InitializeNeverHaveIEverGame event,
    Emitter<NeverHaveIEverState> emit,
  ) async {
    emit(NeverHaveIEverLoading());

    // carico eventuale lista di asked IDs
    final gs = event.initialSession.gameState;
    if (gs != null && gs['asked_question_ids'] is List) {
      _askedQuestionIds = List<String>.from(gs['asked_question_ids'] as List);
    }

    _startStreams(event.initialSession.id);

    final playersEither =
        await _streamLobbyPlayers(event.initialSession.id).first;
    await playersEither.fold(
      (fail) async {
        emit(NeverHaveIEverError(
            "Errore nel caricamento dei partecipanti: ${fail.message}"));
      },
      (initialPlayers) async {
        _currentPlayersList = initialPlayers;
        _isSinglePlayerLocalMode = initialPlayers.length == 1;

        final questionsResult = await _getNeverHaveIEverCards(
          GetNeverHaveIEverCardsParams(sessionId: event.initialSession.id),
        );
        await questionsResult.fold(
          (failure) async {
            emit(NeverHaveIEverError(
                "Errore nel caricamento delle domande: ${failure.message}"));
          },
          (questions) async {
            _allQuestionsList = questions;

            if (_allQuestionsList.isEmpty && _isAdmin(event.initialSession)) {
              emit(NeverHaveIEverError(
                  "Nessuna domanda trovata per iniziare la partita."));
              return;
            }

            // se admin e non c'è domanda corrente, scelgo la prima unica
            if (_isAdmin(event.initialSession) &&
                (gs == null || gs['current_question_id'] == null) &&
                _allQuestionsList.isNotEmpty) {
              // filtro quelle non ancora usate
              final available = _allQuestionsList
                  .where((q) => !_askedQuestionIds.contains(q.id))
                  .toList();
              final firstQ = available[Random().nextInt(available.length)];
              _askedQuestionIds.add(firstQ.id);

              final newGameState = {
                'current_question_id': firstQ.id,
                'asked_question_ids': _askedQuestionIds,
              };

              if (_isSinglePlayerLocalMode) {
                final updated = event.initialSession.copyWith(
                  gameState: newGameState,
                );
                emit(_buildGameReadyState(updated, _currentPlayersList));
              } else {
                await _updateGameState(UpdateGameStateParams(
                  sessionId: event.initialSession.id,
                  newGameState: newGameState,
                ));
                // aspetto lo stream
              }
            } else {
              emit(
                _buildGameReadyState(event.initialSession, _currentPlayersList),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _onNextQuestionRequested(
      NextQuestionRequested event, Emitter<NeverHaveIEverState> emit) async {
    if (state is! NeverHaveIEverGameReady) return;
    final s = state as NeverHaveIEverGameReady;
    if (!_isAdmin(s.session)) return;

    // limite 200
    if (_askedQuestionIds.length >= 200) {
      emit(const NeverHaveIEverError(
          "Hai già raggiunto il limite di 200 domande uniche."));
      return;
    }

    final available = _allQuestionsList
        .where((q) => !_askedQuestionIds.contains(q.id))
        .toList();
    if (available.isEmpty) {
      emit(const NeverHaveIEverError(
          "Non ci sono più domande nuove da proporre."));
      return;
    }

    final randomQ = available[Random().nextInt(available.length)];
    _askedQuestionIds.add(randomQ.id);

    final newGameState = {
      ...?s.session.gameState,
      'current_question_id': randomQ.id,
      'asked_question_ids': _askedQuestionIds,
    };

    if (_isSinglePlayerLocalMode) {
      final updated = s.session.copyWith(gameState: newGameState);
      emit(_buildGameReadyState(updated, _currentPlayersList));
    } else {
      final result = await _updateGameState(UpdateGameStateParams(
        sessionId: s.session.id,
        newGameState: newGameState,
      ));
      result.fold(
        (failure) => emit(NeverHaveIEverError("Errore: ${failure.message}")),
        (_) => null,
      );
    }
  }

  // =========================== STREAM HANDLERS ===========================

  void _onSessionUpdated(
      _NeverHaveIEverSessionUpdated event, Emitter<NeverHaveIEverState> emit) {
    if (event.session.status != GameStatus.inProgress) {
      _cancelSubscriptions();
      emit(NeverHaveIEverInitial());
      return;
    }

    // sync asked IDs
    final gs = event.session.gameState;
    if (gs?['asked_question_ids'] is List) {
      _askedQuestionIds = List<String>.from(gs!['asked_question_ids']);
    }

    if (_isSinglePlayerLocalMode && state is NeverHaveIEverGameReady) {
      final s = state as NeverHaveIEverGameReady;
      final merged = s.session.copyWith(
        status: event.session.status,
      );
      emit(_buildGameReadyState(merged, _currentPlayersList));
    } else {
      emit(_buildGameReadyState(event.session, _currentPlayersList));
    }
  }

  void _onPlayersUpdated(
      _NeverHaveIEverPlayersUpdated event, Emitter<NeverHaveIEverState> emit) {
    _currentPlayersList = event.players;
    if (state is NeverHaveIEverGameReady) {
      final s = state as NeverHaveIEverGameReady;
      emit(_buildGameReadyState(s.session, _currentPlayersList));
    }
  }

  void _onStreamErrorOccurred(_NeverHaveIEverStreamErrorOccurred event,
      Emitter<NeverHaveIEverState> emit) {
    emit(NeverHaveIEverError(event.message));
    _cancelSubscriptions();
  }

  // =====================================================================
  // UTILITY METHODS
  // =====================================================================

  NeverHaveIEverGameReady _buildGameReadyState(
    GameSession session,
    List<GamePlayer> players,
  ) {
    NeverHaveIEverQuestion? currentQuestion;
    final gs = session.gameState;
    if (gs != null && gs['current_question_id'] != null) {
      final qid = gs['current_question_id'] as String;
      try {
        currentQuestion = _allQuestionsList.firstWhere((q) => q.id == qid);
      } catch (_) {}
    }
    return NeverHaveIEverGameReady(
      session: session,
      players: players,
      allQuestions: _allQuestionsList,
      isAdmin: _isAdmin(session),
      currentQuestion: currentQuestion,
      currentPlayerName: _getPlayerName(session.currentTurnUserId, players),
    );
  }

  void _startStreams(String sessionId) {
    _cancelSubscriptions();
    _sessionSubscription = _streamGameSession(sessionId).listen(
      (either) => either.fold(
        (f) => add(_NeverHaveIEverStreamErrorOccurred(f.message)),
        (s) => add(_NeverHaveIEverSessionUpdated(s)),
      ),
      onError: (e) => add(_NeverHaveIEverStreamErrorOccurred(e.toString())),
    );
    _playersSubscription = _streamLobbyPlayers(sessionId).listen(
      (either) => either.fold(
        (f) => add(_NeverHaveIEverStreamErrorOccurred(f.message)),
        (p) => add(_NeverHaveIEverPlayersUpdated(p)),
      ),
      onError: (e) => add(_NeverHaveIEverStreamErrorOccurred(e.toString())),
    );
  }

  String? _getPlayerName(String? userId, List<GamePlayer> players) {
    if (userId == null) return null;
    try {
      return players.firstWhere((p) => p.userId == userId).userName;
    } catch (_) {
      return null;
    }
  }

  void _cancelSubscriptions() {
    _sessionSubscription?.cancel();
    _playersSubscription?.cancel();
    _sessionSubscription = null;
    _playersSubscription = null;
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
