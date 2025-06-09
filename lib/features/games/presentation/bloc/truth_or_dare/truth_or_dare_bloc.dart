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
  // =====================================================================
  // PROPERTIES
  // =====================================================================
  final GetTruthOrDareCards _getTruthOrDareCards;
  final StreamGameSession _streamGameSession;
  final StreamLobbyPlayers _streamLobbyPlayers;
  final UpdateGameState _updateGameState;
  final AppUserCubit _appUserCubit;

  StreamSubscription<dynamic>? _sessionSubscription;
  StreamSubscription<dynamic>? _playersSubscription;
  List<TruthOrDareQuestion> _allQuestionsList = [];

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
  // HELPER METHODS (INSTANCE)
  // =====================================================================
  bool _isAdmin(GameSession? session) =>
      session != null && _currentUser?.id == session.adminId;

  // =====================================================================
  // CONSTRUCTOR
  // =====================================================================
  TruthOrDareBloc({
    required GetTruthOrDareCards getTruthOrDareCards,
    required StreamGameSession streamGameSession,
    required StreamLobbyPlayers streamLobbyPlayers,
    required UpdateGameState updateGameState,
    required AppUserCubit appUserCubit,
  })  : _getTruthOrDareCards = getTruthOrDareCards,
        _streamGameSession = streamGameSession,
        _streamLobbyPlayers = streamLobbyPlayers,
        _updateGameState = updateGameState,
        _appUserCubit = appUserCubit,
        super(TruthOrDareInitial()) {
    on<InitializeTruthOrDareGame>(_onInitializeTruthOrDareGame);
    on<CardTypeChosen>(_onCardTypeChosen);
    on<PlayerTaskOutcomeSubmitted>(_onPlayerTaskOutcomeSubmitted);
    on<ChangeQuestionRequested>(_onChangeQuestionRequested);
    on<_TruthOrDareSessionUpdated>(_onSessionUpdated);
    on<_TruthOrDarePlayersUpdated>(_onPlayersUpdated);
    on<_TruthOrDareStreamErrorOccurred>(_onStreamErrorOccurred);
  }

  // =====================================================================
  // EVENT HANDLERS
  // =====================================================================

  // ------------------ ON INITIALIZE TRUTH OR DARE GAME ------------------ //
  Future<void> _onInitializeTruthOrDareGame(
      InitializeTruthOrDareGame event, Emitter<TruthOrDareState> emit) async {
    emit(TruthOrDareLoading());
    final result = await _getTruthOrDareCards(GetTruthOrDareCardsParams());

    await result.fold(
      (failure) async {
        emit(TruthOrDareError(failure.message));
      },
      (questions) async {
        _allQuestionsList = questions;
        _startStreams(event.initialSession.id);

        final playersEither =
            await _streamLobbyPlayers(event.initialSession.id).first;

        await playersEither.fold((fail) async {
          emit(TruthOrDareError("Failed to load players: ${fail.message}"));
        }, (initialPlayers) async {
          TruthOrDareQuestion? initialQuestion;
          if (event.initialSession.gameState != null &&
              event.initialSession.gameState!['current_question_id'] != null) {
            final questionId = event
                .initialSession.gameState!['current_question_id'] as String;
            try {
              initialQuestion =
                  _allQuestionsList.firstWhere((q) => q.id == questionId);
            } catch (e) {
              // If question not found, initialQuestion remains null
            }
          }

          final initialState = TruthOrDareGameReady(
            session: event.initialSession,
            players: initialPlayers,
            allQuestions: _allQuestionsList,
            isAdmin: _isAdmin(event.initialSession),
            currentQuestion: initialQuestion,
            canChangeCurrentQuestion: initialQuestion == null,
          );
          emit(initialState);
        });
      },
    );
  }

  // ------------------ ON CARD TYPE CHOSEN ------------------ //
  Future<void> _onCardTypeChosen(
      CardTypeChosen event, Emitter<TruthOrDareState> emit) async {
    if (state is TruthOrDareGameReady) {
      final currentReadyState = state as TruthOrDareGameReady;
      final List<TruthOrDareQuestion> availableQuestions =
          _allQuestionsList.where((q) => q.type == event.cardType).toList();

      if (availableQuestions.isNotEmpty) {
        final randomQuestion =
            availableQuestions[Random().nextInt(availableQuestions.length)];

        final immediateState = currentReadyState.copyWith(
          currentQuestion: randomQuestion,
          canChangeCurrentQuestion: true,
          allQuestions: _allQuestionsList,
        );
        emit(immediateState);

        final newGameState = {
          'current_question_id': randomQuestion.id,
          'current_question_type': randomQuestion.type.name,
        };
        final result = await _updateGameState(UpdateGameStateParams(
          sessionId: currentReadyState.session.id,
          newGameState: newGameState,
        ));

        result.fold((failure) {
          emit(currentReadyState.copyWith(
              currentQuestion: null, allQuestions: _allQuestionsList));
          emit(TruthOrDareError("Errore selezione carta: ${failure.message}"));
        }, (_) {
          // State already updated optimistically, stream will confirm or correct
        });
      } else {
        emit(TruthOrDareError(
            "Nessuna domanda disponibile per ${event.cardType}."));
        Future.delayed(const Duration(seconds: 2), () {
          if (state is TruthOrDareError) {
            emit(currentReadyState.copyWith(allQuestions: _allQuestionsList));
          }
        });
      }
    }
  }

  // ------------------ ON PLAYER TASK OUTCOME SUBMITTED ------------------ //
  Future<void> _onPlayerTaskOutcomeSubmitted(
      PlayerTaskOutcomeSubmitted event, Emitter<TruthOrDareState> emit) async {
    if (state is! TruthOrDareGameReady) return;
    final currentReadyState = state as TruthOrDareGameReady;
    final String? currentTurnUserId =
        currentReadyState.session.currentTurnUserId;

    if (currentTurnUserId == null || currentReadyState.players.isEmpty) {
      emit(TruthOrDareError(
          "Stato del gioco non valido per determinare il prossimo turno."));
      return;
    }

    final nextPlayerUserId = currentReadyState.players.length > 1
        ? _getNextPlayerUserId(currentTurnUserId, currentReadyState.players)
        : currentTurnUserId;

    final newGameState = {
      'current_question_id': null,
      'current_question_type': null,
    };

    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: currentReadyState.session.id,
      newGameState: newGameState,
      currentTurnUserId: nextPlayerUserId,
      status: GameStatus.inProgress,
    ));

    result.fold((failure) {
      emit(TruthOrDareError("Errore avanzamento turno: ${failure.message}"));
    }, (_) {
      // Stream will update the state
    });
  }

  // ------------------ ON CHANGE QUESTION REQUESTED ------------------ //
  void _onChangeQuestionRequested(
      ChangeQuestionRequested event, Emitter<TruthOrDareState> emit) async {
    if (state is TruthOrDareGameReady) {
      final currentReadyState = state as TruthOrDareGameReady;

      if (currentReadyState.currentQuestion == null ||
          !currentReadyState.canChangeCurrentQuestion) {
        return;
      }

      final currentType = currentReadyState.currentQuestion!.type;
      final List<TruthOrDareQuestion> availableQuestions = _allQuestionsList
          .where((q) =>
              q.type == currentType &&
              q.id != currentReadyState.currentQuestion!.id)
          .toList();

      if (availableQuestions.isNotEmpty) {
        final randomQuestion =
            availableQuestions[Random().nextInt(availableQuestions.length)];
        emit(currentReadyState.copyWith(
          currentQuestion: randomQuestion,
          canChangeCurrentQuestion: false,
          allQuestions: _allQuestionsList,
        ));

        final newGameState = {
          'current_question_id': randomQuestion.id,
          'current_question_type': randomQuestion.type.name,
        };
        final result = await _updateGameState(UpdateGameStateParams(
          sessionId: currentReadyState.session.id,
          newGameState: newGameState,
        ));

        result.fold((failure) {
          emit(currentReadyState.copyWith(
              currentQuestion: currentReadyState.currentQuestion,
              canChangeCurrentQuestion: true,
              allQuestions: _allQuestionsList));
          emit(TruthOrDareError("Errore cambio domanda: ${failure.message}"));
        }, (_) {
          // State already updated optimistically, stream will confirm or correct
        });
      } else {
        emit(currentReadyState.copyWith(
          canChangeCurrentQuestion: false,
          allQuestions: _allQuestionsList,
        ));
      }
    }
  }

  // =====================================================================
  // INTERNAL EVENT HANDLERS / STREAM UPDATERS
  // =====================================================================

  // ------------------ ON SESSION UPDATED ------------------ //
  void _onSessionUpdated(
      _TruthOrDareSessionUpdated event, Emitter<TruthOrDareState> emit) {
    if (state is TruthOrDareGameReady) {
      final currentReadyState = state as TruthOrDareGameReady;
      final previousTurnUserId = currentReadyState.session.currentTurnUserId;

      if (event.session.status != GameStatus.inProgress) {
        _cancelSubscriptions();
        emit(TruthOrDareInitial());
        return;
      }

      bool turnChanged = previousTurnUserId != event.session.currentTurnUserId;
      TruthOrDareQuestion? updatedQuestion;

      if (event.session.gameState != null &&
          event.session.gameState!['current_question_id'] != null) {
        final questionId =
            event.session.gameState!['current_question_id'] as String;
        try {
          updatedQuestion =
              _allQuestionsList.firstWhere((q) => q.id == questionId);
        } catch (e) {
          updatedQuestion = null;
        }
      } else {
        updatedQuestion = null;
      }

      final newState = currentReadyState.copyWith(
        session: event.session,
        players: currentReadyState.players,
        allQuestions: _allQuestionsList,
        isAdmin: _isAdmin(event.session),
        currentQuestion: updatedQuestion,
        clearCurrentQuestion: updatedQuestion == null,
        canChangeCurrentQuestion: turnChanged
            ? true
            : (updatedQuestion == null
                ? true
                : currentReadyState.canChangeCurrentQuestion),
      );
      emit(newState);
    } else if (state is TruthOrDareLoading && _sessionSubscription != null) {
      // Still loading, session update might be the first one.
      // The _onInitializeTruthOrDareGame should handle emitting GameReady.
    } else {
      // Potentially an unexpected state, or game ended and state is TruthOrDareInitial.
    }
  }

  // ------------------ ON PLAYERS UPDATED ------------------ //
  void _onPlayersUpdated(
      _TruthOrDarePlayersUpdated event, Emitter<TruthOrDareState> emit) {
    if (state is TruthOrDareGameReady) {
      final currentReadyState = state as TruthOrDareGameReady;
      emit(currentReadyState.copyWith(
        players: event.players,
        allQuestions: _allQuestionsList,
      ));
    } else if (state is TruthOrDareLoading && _playersSubscription != null) {
      // Still loading, players update might come.
      // The _onInitializeTruthOrDareGame should handle emitting GameReady with initial players.
    }
  }

  // ------------------ ON STREAM ERROR OCCURRED ------------------ //
  void _onStreamErrorOccurred(
      _TruthOrDareStreamErrorOccurred event, Emitter<TruthOrDareState> emit) {
    emit(TruthOrDareError(event.message));
  }

  // =====================================================================
  // UTILITY METHODS
  // =====================================================================

  // ------------------ START STREAMS ------------------ //
  void _startStreams(String sessionId) {
    _cancelSubscriptions();

    _sessionSubscription = _streamGameSession(sessionId).listen(
      (eitherSession) => eitherSession.fold(
        (failure) => add(_TruthOrDareStreamErrorOccurred(
            'Errore sessione: ${failure.message}')),
        (session) => add(_TruthOrDareSessionUpdated(session)),
      ),
      onError: (error) => add(
          _TruthOrDareStreamErrorOccurred('Errore stream sessione: $error')),
    );

    _playersSubscription = _streamLobbyPlayers(sessionId).listen(
      (eitherPlayers) => eitherPlayers.fold(
        (failure) => add(_TruthOrDareStreamErrorOccurred(
            'Errore giocatori: ${failure.message}')),
        (players) => add(_TruthOrDarePlayersUpdated(players)),
      ),
      onError: (error) => add(
          _TruthOrDareStreamErrorOccurred('Errore stream giocatori: $error')),
    );
  }

  // ------------------ GET NEXT PLAYER USER ID ------------------ //
  String _getNextPlayerUserId(String currentUserId, List<GamePlayer> players) {
    if (players.isEmpty) {
      return currentUserId;
    }
    final currentIndex = players.indexWhere((p) => p.userId == currentUserId);
    if (currentIndex == -1) {
      return players.first.userId;
    }
    final nextIndex = (currentIndex + 1) % players.length;
    return players[nextIndex].userId;
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
