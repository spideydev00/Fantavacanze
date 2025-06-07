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
  final GetTruthOrDareCards _getTruthOrDareCards;
  final UpdateGameState _updateGameState;
  final StreamGameSession _streamGameSession;
  final StreamLobbyPlayers _streamLobbyPlayers;
  final AppUserCubit _appUserCubit;

  StreamSubscription<dynamic>? _sessionSubscription;
  StreamSubscription<dynamic>? _playersSubscription;
  List<TruthOrDareQuestion> _availableTruths = [];
  List<TruthOrDareQuestion> _availableDares = [];

  auth_user.User? get _currentUser {
    final userState = _appUserCubit.state;
    if (userState is AppUserIsLoggedIn) {
      return userState.user;
    }
    return null;
  }

  bool _isAdmin(GameSession session) => _currentUser?.id == session.adminId;

  TruthOrDareBloc({
    required GetTruthOrDareCards getTruthOrDareCards,
    required UpdateGameState updateGameState,
    required StreamGameSession streamGameSession,
    required StreamLobbyPlayers streamLobbyPlayers,
    required AppUserCubit appUserCubit,
  })  : _getTruthOrDareCards = getTruthOrDareCards,
        _updateGameState = updateGameState,
        _streamGameSession = streamGameSession,
        _streamLobbyPlayers = streamLobbyPlayers,
        _appUserCubit = appUserCubit,
        super(TruthOrDareInitial()) {
    on<InitializeTruthOrDareGame>(_onInitializeTruthOrDareGame);
    on<CardTypeChosen>(_onCardTypeChosen);
    on<NextPlayerTurn>(_onNextPlayerTurn);
    on<_GameStateUpdated>(_onGameStateUpdated);
    on<_TruthOrDareErrorOccurred>(_onErrorOccurred);
  }

  Future<void> _onInitializeTruthOrDareGame(
      InitializeTruthOrDareGame event, Emitter<TruthOrDareState> emit) async {
    emit(TruthOrDareLoading());

    final cardsResult = await _getTruthOrDareCards(
        GetTruthOrDareCardsParams(limit: 100)); // Fetch more cards

    await cardsResult.fold(
      (failure) async => emit(TruthOrDareError(failure.message)),
      (questions) async {
        _availableTruths = questions
            .where((q) => q.type == TruthOrDareCardType.truth)
            .toList();
        _availableDares =
            questions.where((q) => q.type == TruthOrDareCardType.dare).toList();

        _startStreams(event.initialSession.id, emit);

        // Fetch initial players list
        final playersStream = _streamLobbyPlayers(event.initialSession.id);
        final eitherPlayers = await playersStream
            .first; // Get the first emission for initial state

        eitherPlayers.fold(
            (failure) => emit(TruthOrDareError(
                "Errore caricamento giocatori: ${failure.message}")),
            (initialPlayers) {
          emit(TruthOrDareGameReady(
            session: event.initialSession,
            allQuestions: questions,
            players: initialPlayers,
            isAdmin: _isAdmin(event.initialSession),
          ));
          // If no current turn user, admin sets it.
          if (event.initialSession.currentTurnUserId == null &&
              _isAdmin(event.initialSession) &&
              initialPlayers.isNotEmpty) {
            add(NextPlayerTurn(initialPlayers.first.userId));
          }
        });
      },
    );
  }

  void _startStreams(String sessionId, Emitter<TruthOrDareState> emit) {
    _sessionSubscription?.cancel();
    _sessionSubscription = _streamGameSession(sessionId).listen(
      (eitherSession) => eitherSession.fold(
        (failure) => add(_TruthOrDareErrorOccurred(
            'Errore stream sessione: ${failure.message}')),
        (session) => add(_GameStateUpdated(session)),
      ),
      onError: (error) =>
          add(_TruthOrDareErrorOccurred('Errore stream sessione: $error')),
    );

    _playersSubscription?.cancel();
    _playersSubscription = _streamLobbyPlayers(sessionId).listen(
      (eitherPlayers) => eitherPlayers.fold((failure) {
        /* Optionally handle player stream error */
      }, (players) {
        if (state is TruthOrDareGameReady) {
          final currentReadyState = state as TruthOrDareGameReady;
          emit(currentReadyState.copyWith(players: players));
        }
      }),
    );
  }

  Future<void> _onCardTypeChosen(
      CardTypeChosen event, Emitter<TruthOrDareState> emit) async {
    if (state is! TruthOrDareGameReady) return;
    final currentReadyState = state as TruthOrDareGameReady;

    if (!_isAdmin(currentReadyState.session)) {
      // Non-admin cannot choose card type, this should be prevented by UI
      return;
    }
    if (currentReadyState.session.currentTurnUserId == null) {
      emit(TruthOrDareError("Seleziona prima un giocatore."));
      emit(currentReadyState); // Re-emit to clear error after a bit
      return;
    }

    TruthOrDareQuestion? chosenQuestion;
    if (event.cardType == TruthOrDareCardType.truth) {
      if (_availableTruths.isNotEmpty) {
        chosenQuestion = _availableTruths
            .removeAt(Random().nextInt(_availableTruths.length));
      } else {
        emit(TruthOrDareError("Finite le carte Verità!"));
        emit(currentReadyState); // Re-emit to clear error
        return;
      }
    } else {
      if (_availableDares.isNotEmpty) {
        chosenQuestion =
            _availableDares.removeAt(Random().nextInt(_availableDares.length));
      } else {
        emit(TruthOrDareError("Finite le carte Obbligo!"));
        emit(currentReadyState); // Re-emit to clear error
        return;
      }
    }

    final newGameState = {
      'current_question_id': chosenQuestion.id,
      'current_question_text': chosenQuestion.content,
      'current_question_type':
          chosenQuestion.type == TruthOrDareCardType.truth ? 'truth' : 'dare',
    };

    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: currentReadyState.session.id,
      newGameState: newGameState,
      // currentTurnUserId remains the same until NextPlayerTurn
    ));

    result.fold(
      (failure) => emit(TruthOrDareError(failure.message)),
      (_) {
        // Game state will be updated via stream, no need to emit here
        // The local state's currentQuestion will be updated in _onGameStateUpdated
      },
    );
  }

  Future<void> _onNextPlayerTurn(
      NextPlayerTurn event, Emitter<TruthOrDareState> emit) async {
    if (state is! TruthOrDareGameReady) return;
    final currentReadyState = state as TruthOrDareGameReady;

    if (!_isAdmin(currentReadyState.session)) {
      return;
    } // Only admin can change turn for now

    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: currentReadyState.session.id,
      newGameState: {}, // Clear current question from game state
      currentTurnUserId: event.nextPlayerId,
    ));

    result.fold((failure) => emit(TruthOrDareError(failure.message)), (_) {
      // State will update via stream. Local currentQuestion will be cleared in _onGameStateUpdated
    });
  }

  void _onGameStateUpdated(
      _GameStateUpdated event, Emitter<TruthOrDareState> emit) {
    if (state is TruthOrDareGameReady) {
      final currentReadyState = state as TruthOrDareGameReady;
      TruthOrDareQuestion? newCurrentQuestion;
      bool shouldClearQuestion = true;

      if (event.session.gameState != null &&
          event.session.gameState!.containsKey('current_question_id')) {
        final qId = event.session.gameState!['current_question_id'].toString();
        final qContent =
            event.session.gameState!['current_question_text'] as String;
        final qTypeString =
            event.session.gameState!['current_question_type'] as String;
        newCurrentQuestion = TruthOrDareQuestion(
          id: qId,
          content: qContent,
          type: qTypeString == 'truth'
              ? TruthOrDareCardType.truth
              : TruthOrDareCardType.dare,
        );
        shouldClearQuestion = false;
      }

      emit(currentReadyState.copyWith(
        session: event.session,
        currentQuestion: newCurrentQuestion, // Update or clear the question
        clearCurrentQuestion:
            shouldClearQuestion, // Explicitly clear if no question in game state
        isAdmin: _isAdmin(
            event.session), // Re-evaluate admin status if session changes
      ));

      if (event.session.status == GameStatus.finished ||
          event.session.status == GameStatus.waiting) {
        _cancelSubscriptions();
        // Potentially navigate away or show "Game Over" screen
        // For now, just stop listening. UI should react to status change.
      }
    } else if (state is TruthOrDareInitial || state is TruthOrDareLoading) {
      // This might happen if stream fires before full initialization.
      // Or if recovering from an error.
      // We need allQuestions and players to emit TruthOrDareGameReady.
      // This path should ideally be covered by _onInitializeTruthOrDareGame.
    }
  }

  void _onErrorOccurred(
      _TruthOrDareErrorOccurred event, Emitter<TruthOrDareState> emit) {
    emit(TruthOrDareError(event.message));
    _cancelSubscriptions(); // Stop listening on fatal error
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
