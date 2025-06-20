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
import 'package:fantavacanze_official/features/games/domain/entities/truth_or_dare_question.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/get_truth_or_dare_cards.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_lobby_players.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_state.dart';

part 'truth_or_dare_event.dart';
part 'truth_or_dare_state.dart';

class TruthOrDareBloc extends Bloc<TruthOrDareEvent, TruthOrDareState> {
  // USE CASES & CUBIT
  final GetTruthOrDareCards _getCards;
  final StreamGameSession _streamSession;
  final StreamLobbyPlayers _streamPlayers;
  final UpdateGameState _updateState;
  final AppUserCubit _appUser;

  // STREAM SUBSCRIPTIONS
  StreamSubscription? _sessionSub;
  StreamSubscription? _playersSub;

  // DOMANDE E STATO
  List<TruthOrDareQuestion> _allQuestionsList = [];
  List<String> _askedQuestionIds = [];
  bool _isSinglePlayerLocalMode = false;

  TruthOrDareBloc({
    required GetTruthOrDareCards getTruthOrDareCards,
    required StreamGameSession streamGameSession,
    required StreamLobbyPlayers streamLobbyPlayers,
    required UpdateGameState updateGameState,
    required AppUserCubit appUserCubit,
  })  : _getCards = getTruthOrDareCards,
        _streamSession = streamGameSession,
        _streamPlayers = streamLobbyPlayers,
        _updateState = updateGameState,
        _appUser = appUserCubit,
        super(TruthOrDareInitial()) {
    on<InitializeTruthOrDareGame>(_onInitialize);
    on<CardTypeChosen>(_onCardChosen);
    on<ChangeQuestionRequested>(_onChangeQuestion);
    on<PlayerTaskOutcomeSubmitted>(_onOutcomeSubmitted);
    on<_TruthOrDareSessionUpdated>(_onSessionUpdated);
    on<_TruthOrDarePlayersUpdated>(_onPlayersUpdated);
    on<_TruthOrDareStreamErrorOccurred>(_onStreamErrorOccurred);
  }

  auth_user.User? get _me {
    final s = _appUser.state;
    return s is AppUserIsLoggedIn ? s.user : null;
  }

  bool _isAdmin(GameSession? sess) => sess != null && sess.adminId == _me?.id;

  // 1) INIZIALIZZAZIONE
  Future<void> _onInitialize(
    InitializeTruthOrDareGame event,
    Emitter<TruthOrDareState> emit,
  ) async {
    emit(TruthOrDareLoading());

    // Riprendo eventuale lista di asked IDs da gameState
    final gs0 = event.initialSession.gameState;
    if (gs0?['asked_question_ids'] is List) {
      _askedQuestionIds =
          List<String>.from(gs0!['asked_question_ids'] as List<dynamic>);
    }

    // Carico tutte le carte
    final cardsEither = await _getCards(GetTruthOrDareCardsParams());
    await cardsEither.fold(
      (failure) async => emit(TruthOrDareError(failure.message)),
      (cards) async {
        _allQuestionsList = cards;

        // Stream dei giocatori per decidere single vs multiplayer
        final playersEither =
            await _streamPlayers(event.initialSession.id).first;
        await playersEither.fold(
          (failure) async => emit(TruthOrDareError(failure.message)),
          (players) async {
            _isSinglePlayerLocalMode = players.length == 1;
            if (_isSinglePlayerLocalMode) {
              // Imposta subito il currentTurnUserId per evitare blocchi
              final localSession = event.initialSession.copyWith(
                currentTurnUserId: _me?.id,
              );
              
              emit(TruthOrDareGameReady(
                session: localSession,
                players: players,
                allQuestions: _allQuestionsList,
                isAdmin: _isAdmin(localSession),
                currentQuestion: null,
                canChangeCurrentQuestion: true,
              ));
              
              return;
            }

            _startStreams(event.initialSession.id);

            // Stato iniziale: nessuna domanda scelta
            emit(TruthOrDareGameReady(
              session: event.initialSession,
              players: players,
              allQuestions: _allQuestionsList,
              isAdmin: _isAdmin(event.initialSession),
              currentQuestion: null,
              canChangeCurrentQuestion: true,
            ));
          },
        );
      },
    );
  }

  // 2) SCELTA CARTA (truth o dare)
  Future<void> _onCardChosen(
    CardTypeChosen event,
    Emitter<TruthOrDareState> emit,
  ) async {
    if (state is! TruthOrDareGameReady) return;
    final s = state as TruthOrDareGameReady;
    final myId = _me?.id;
    if (s.session.currentTurnUserId != myId) return;

    // Filtra le domande mai usate di quel tipo
    final available = _allQuestionsList
        .where((q) =>
            q.type == event.cardType && !_askedQuestionIds.contains(q.id))
        .toList();
    if (available.isEmpty) {
      emit(TruthOrDareError("Non ci sono più domande di questo tipo."));
      return;
    }
    final pick = available[Random().nextInt(available.length)];
    _askedQuestionIds.add(pick.id);

    final newGs = <String, dynamic>{
      'current_question_id': pick.id,
      'current_question_type': pick.type.name,
      'asked_question_ids': _askedQuestionIds,
      'can_change': true,
    };

    if (_isSinglePlayerLocalMode) {
      // SINGLE-PLAYER: tutto in locale
      final localSession = s.session.copyWith(gameState: newGs);
      emit(s.copyWith(
        session: localSession,
        currentQuestion: pick,
        canChangeCurrentQuestion: true,
      ));
    } else {
      // MULTIPLAYER: aggiorno il server e aspetto il stream
      await _updateState(UpdateGameStateParams(
        sessionId: s.session.id,
        newGameState: newGs,
      ));
    }
  }

  // 3) REFRESH CARTA (una sola volta)
  Future<void> _onChangeQuestion(
    ChangeQuestionRequested event,
    Emitter<TruthOrDareState> emit,
  ) async {
    if (state is! TruthOrDareGameReady) return;
    final s = state as TruthOrDareGameReady;
    final cur = s.currentQuestion;
    final myId = _me?.id;
    if (cur == null || s.session.currentTurnUserId != myId) return;
    if (!s.canChangeCurrentQuestion) return;

    final available = _allQuestionsList
        .where((q) =>
            q.type == cur.type &&
            q.id != cur.id &&
            !_askedQuestionIds.contains(q.id))
        .toList();
    if (available.isEmpty) {
      final disableGs = {
        ...?s.session.gameState,
        'can_change': false,
      };
      if (_isSinglePlayerLocalMode) {
        final localSession = s.session.copyWith(gameState: disableGs);
        emit(s.copyWith(
          session: localSession,
          canChangeCurrentQuestion: false,
        ));
      } else {
        await _updateState(UpdateGameStateParams(
          sessionId: s.session.id,
          newGameState: disableGs,
        ));
      }
      return;
    }

    final pick = available[Random().nextInt(available.length)];
    _askedQuestionIds.add(pick.id);
    final newGs = <String, dynamic>{
      'current_question_id': pick.id,
      'current_question_type': pick.type.name,
      'asked_question_ids': _askedQuestionIds,
      'can_change': false,
    };

    if (_isSinglePlayerLocalMode) {
      final localSession = s.session.copyWith(gameState: newGs);
      emit(s.copyWith(
        session: localSession,
        currentQuestion: pick,
        canChangeCurrentQuestion: false,
      ));
    } else {
      await _updateState(UpdateGameStateParams(
        sessionId: s.session.id,
        newGameState: newGs,
      ));
    }
  }

  // 4) OUTCOME: “fatto” o “non fatto” → reset e cambio turno
  Future<void> _onOutcomeSubmitted(
    PlayerTaskOutcomeSubmitted event,
    Emitter<TruthOrDareState> emit,
  ) async {
    if (state is! TruthOrDareGameReady) return;
    final s = state as TruthOrDareGameReady;
    final turnId = s.session.currentTurnUserId;
    final myId = _me?.id;
    if (turnId != myId) return;

    final nextId = _isSinglePlayerLocalMode
        ? turnId
        : _getNextPlayerUserId(turnId!, s.players);

    final newGs = <String, dynamic>{
      'current_question_id': null,
      'current_question_type': null,
      'asked_question_ids': _askedQuestionIds,
      'can_change': true,
    };

    if (_isSinglePlayerLocalMode) {
      final localSession = s.session.copyWith(
        gameState: newGs,
        currentTurnUserId: nextId,
      );
      emit(s.copyWith(
        session: localSession,
        canChangeCurrentQuestion: true,
        clearCurrentQuestion: true,
      ));
    } else {
      await _updateState(UpdateGameStateParams(
        sessionId: s.session.id,
        newGameState: newGs,
        currentTurnUserId: nextId,
        status: GameStatus.inProgress,
      ));
    }
  }

  // ====== STREAM HANDLERS (MULTIPLAYER) ======

  void _onSessionUpdated(
    _TruthOrDareSessionUpdated event,
    Emitter<TruthOrDareState> emit,
  ) {
    final sess = event.session;
    if (sess.status != GameStatus.inProgress) {
      _cancelStreams();
      emit(TruthOrDareInitial());
      return;
    }

    final gs = sess.gameState;
    if (gs?['asked_question_ids'] is List) {
      _askedQuestionIds =
          List<String>.from(gs!['asked_question_ids'] as List<dynamic>);
    }
    final canChange = gs?['can_change'] as bool? ?? true;

    TruthOrDareQuestion? curr;
    final qid = gs?['current_question_id'] as String?;
    if (qid != null) {
      curr = _allQuestionsList.firstWhere(
        (q) => q.id == qid,
      );
    }

    final players = (state is TruthOrDareGameReady)
        ? (state as TruthOrDareGameReady).players
        : <GamePlayer>[];

    emit(TruthOrDareGameReady(
      session: sess,
      players: players,
      allQuestions: _allQuestionsList,
      isAdmin: _isAdmin(sess),
      currentQuestion: curr,
      canChangeCurrentQuestion: curr != null ? canChange : true,
    ));
  }

  void _onPlayersUpdated(
    _TruthOrDarePlayersUpdated event,
    Emitter<TruthOrDareState> emit,
  ) {
    if (state is TruthOrDareGameReady) {
      emit((state as TruthOrDareGameReady).copyWith(players: event.players));
    }
  }

  void _onStreamErrorOccurred(
    _TruthOrDareStreamErrorOccurred event,
    Emitter<TruthOrDareState> emit,
  ) {
    emit(TruthOrDareError(event.message));
  }

  // ====== HELPERS ======

  void _startStreams(String sessionId) {
    _cancelStreams();
    _sessionSub = _streamSession(sessionId).listen(
      (either) => either.fold(
        (fail) => add(_TruthOrDareStreamErrorOccurred(fail.message)),
        (sess) => add(_TruthOrDareSessionUpdated(sess)),
      ),
      onError: (e) => add(_TruthOrDareStreamErrorOccurred(e.toString())),
    );
    _playersSub = _streamPlayers(sessionId).listen(
      (either) => either.fold(
        (fail) => add(_TruthOrDareStreamErrorOccurred(fail.message)),
        (pls) => add(_TruthOrDarePlayersUpdated(pls)),
      ),
      onError: (e) => add(_TruthOrDareStreamErrorOccurred(e.toString())),
    );
  }

  String _getNextPlayerUserId(String current, List<GamePlayer> pls) {
    final idx = pls.indexWhere((p) => p.userId == current);
    if (idx < 0) return pls.first.userId;
    return pls[(idx + 1) % pls.length].userId;
  }

  void _cancelStreams() {
    _sessionSub?.cancel();
    _playersSub?.cancel();
    _sessionSub = null;
    _playersSub = null;
  }

  @override
  Future<void> close() {
    _cancelStreams();
    return super.close();
  }
}
