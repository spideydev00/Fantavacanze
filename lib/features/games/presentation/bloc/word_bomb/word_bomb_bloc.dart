import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/core/constants/game_constants.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart'
    as auth_user;
import 'package:fantavacanze_official/features/games/domain/usecases/set_word_bomb_trial_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/games/data/models/word_bomb_game_state_model.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/entities/word_bomb_game_state.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_lobby_players.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_player.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_state.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/word_bomb/word_bomb_strategic_action_type.dart';

part 'word_bomb_event.dart';
part 'word_bomb_state.dart';

// =====================================================================
// CONSTANTS
// =====================================================================
const int _wordBombRoundDurationMs = 60000;
const int _timerIntervalMs = 100;
const int _buyTimeBonusMs = 10000;

class WordBombBloc extends Bloc<WordBombEvent, WordBombState> {
  // =====================================================================
  // PROPERTIES
  // =====================================================================
  final UpdateGameState _updateGameState;
  final UpdateGamePlayer _updateGamePlayer;
  final StreamGameSession _streamGameSession;
  final StreamLobbyPlayers _streamLobbyPlayers;
  final AppUserCubit _appUserCubit;
  final SetWordBombTrialStatus _setWordBombTrialStatus;

  StreamSubscription<dynamic>? _sessionSubscription;
  StreamSubscription<dynamic>? _playersSubscription;
  Timer? _roundTimer;
  List<String> _categories = [];
  List<GamePlayer> _currentPlayersList = [];
  bool _isProcessingStrategicActionConfirmation = false;

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
  WordBombBloc({
    required UpdateGameState updateGameState,
    required UpdateGamePlayer updateGamePlayer,
    required StreamGameSession streamGameSession,
    required StreamLobbyPlayers streamLobbyPlayers,
    required AppUserCubit appUserCubit,
    required SetWordBombTrialStatus setWordBombTrialStatus,
  })  : _updateGameState = updateGameState,
        _updateGamePlayer = updateGamePlayer,
        _streamGameSession = streamGameSession,
        _streamLobbyPlayers = streamLobbyPlayers,
        _appUserCubit = appUserCubit,
        _setWordBombTrialStatus = setWordBombTrialStatus,
        super(WordBombInitial()) {
    on<InitializeWordBombGame>(_onInitializeWordBombGame);
    on<SubmitWord>(_onSubmitWord);
    on<PauseGameTriggered>(_onPauseGameTriggered);
    on<ResumeGameTriggered>(_onResumeGameTriggered);
    on<NextPlayerTurnRequested>(_onNextPlayerTurnRequested);
    on<_WordBombGameStateUpdated>(_onWordBombGameStateUpdated);
    on<_TimerTick>(_onTimerTick);
    on<_WordBombErrorOccurred>(_onErrorOccurred);
    on<ActivateTrialRequested>(_onActivateTrialRequested);
    on<RequestStrategicAction>(_onRequestStrategicAction);
    on<ConfirmStrategicAction>(_onConfirmStrategicAction);
    on<CancelStrategicAction>(_onCancelStrategicAction);
    on<ActivateGhostProtocolRequested>(_onActivateGhostProtocolRequested);
    on<DeactivateGhostProtocolDueToTimeout>(
        _onDeactivateGhostProtocolDueToTimeout);
    on<PlayerExploded>(_onPlayerExploded);
    on<PlayerAcceptedDefeat>(_onPlayerAcceptedDefeat);
    on<ChallengeInitiated>(_onChallengeInitiated);
    on<ClearWordBombErrorMessage>(_onClearWordBombErrorMessage);
  }

  // =====================================================================
  // EVENT HANDLERS
  // =====================================================================

  // ------------------ ON INITIALIZE WORD BOMB GAME ------------------ //
  Future<void> _onInitializeWordBombGame(
    InitializeWordBombGame event,
    Emitter<WordBombState> emit,
  ) async {
    final newSessionId = event.initialSession.id;
    final newSessionStatus = event.initialSession.status;

    if (state is WordBombSessionState) {
      final currentSessionState = state as WordBombSessionState;
      if (currentSessionState.session.id == newSessionId &&
          currentSessionState.session.status == newSessionStatus) {
        // Already initialized with this session and status, perhaps a redundant call.
        // Re-emit current state to be safe or just return.
        // For now, let's ensure streams are (re)started if needed.
        _startStreams(newSessionId, emit); // Ensure streams are active
        // If gameState is present, _emitStateFromSession might be appropriate
        // but let's assume the stream will handle it if already initialized.
        // If it's already in a game active state, just return.
        if (currentSessionState is WordBombGameActive ||
            currentSessionState is WordBombPaused) {
          return;
        }
      } else {
        // New session ID or status, proceed with full initialization.
        _cancelSubscriptions(); // Cancel old subs if session ID changed
      }
    } else {
      // Not a session state, definitely proceed with initialization.
      _cancelSubscriptions();
    }

    emit(WordBombLoading());
    _categories = List<String>.from(wordBombCategories);
    _startStreams(event.initialSession.id, emit);

    final playersEither =
        await _streamLobbyPlayers(event.initialSession.id).first;

    await playersEither.fold(
      (failure) async {
        emit(WordBombError(
            "Errore durante il caricamento dei giocatori: ${failure.message}"));
      },
      (initialPlayers) async {
        _currentPlayersList = initialPlayers;
        if (_isAdmin(event.initialSession)) {
          if (event.initialSession.gameState == null &&
              event.initialSession.status == GameStatus.inProgress) {
            await _adminInitializeNewRound(event.initialSession, emit);
          } else if (event.initialSession.gameState != null ||
              event.initialSession.status == GameStatus.waiting) {
            // Game state already exists, or game is waiting. Emit based on it.
            _emitStateFromSession(
                event.initialSession, _currentPlayersList, emit);
          } else {
            // Fallback, should be covered by above. Emit loading or let stream handle.
            // For safety, if admin and inProgress but gameState is null, _adminInitializeNewRound is key.
            // If not inProgress, _emitStateFromSession will show Loading for waiting.
            _emitStateFromSession(
                event.initialSession, _currentPlayersList, emit);
          }
        } else {
          // Non-admin:
          // The BLoC is already in WordBombLoading state (emitted above).
          // Streams are started. _currentPlayersList is now populated.
          // We will rely on the _sessionSubscription to fire with the
          // actual game state (once the admin initializes it)
          // which will then call _emitStateFromSession.
          // No need to call _emitStateFromSession here with event.initialSession
          // as it might have gameState:null and just re-emit WordBombLoading.
          // Let the stream provide the first definitive state.
          // If event.initialSession.status is GameStatus.waiting, the WordBombLoading is appropriate.
          // If event.initialSession.status is GameStatus.inProgress (and gameState is null),
          // WordBombLoading is also appropriate, waiting for admin's gameState.
          // So, the WordBombLoading emitted at the start of this method is sufficient for non-admins here.
        }
      },
    );
  }

  // ------------------ ON SUBMIT WORD ------------------ //
  Future<void> _onSubmitWord(
      SubmitWord event, Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive) return;
    final currentActiveState = state as WordBombGameActive;
    final currentSession = currentActiveState.session;
    final currentGameState = currentActiveState.gameState;
    final currentUser = _currentUser;

    if (currentUser == null ||
        currentSession.currentTurnUserId != currentUser.id) {
      emit(currentActiveState.copyWith(
          errorMessage: "Non è il tuo turno.", clearErrorMessage: false));
      return;
    }

    final submittedWord = event.word.toLowerCase().trim();
    if (submittedWord.isEmpty ||
        !submittedWord
            .startsWith(currentGameState.currentLetterSyllable.toLowerCase())) {
      emit(currentActiveState.copyWith(
          errorMessage:
              "Parola non valida o non inizia con la lettera/sillaba corretta.",
          clearErrorMessage: false));
      return;
    }

    if (currentGameState.usedWords
        .any((w) => w.toLowerCase() == submittedWord)) {
      emit(currentActiveState.copyWith(
          errorMessage: "Parola già usata!", clearErrorMessage: false));
      return;
    }

    // Timer is collective: DO NOT cancel _roundTimer here.
    // It will continue based on _emitStateFromSession and _onTimerTick.
    final nextPlayerId = _getNextPlayerId(currentUser.id, _currentPlayersList);

    // Timer fields (roundStartTimeEpochMs, currentTurnTotalDurationMs, etc.) are NOT changed here.
    final updatedGameState = currentGameState.copyWith(
      usedWords: List.from(currentGameState.usedWords)..add(submittedWord),
      isPaused: false,
    );

    final result = await _updateGameState(
      UpdateGameStateParams(
        sessionId: currentSession.id,
        newGameState:
            WordBombGameStateModelExtension.fromEntity(updatedGameState)
                .toJson(),
        currentTurnUserId: nextPlayerId,
      ),
    );

    result.fold(
      (failure) =>
          emit(WordBombError("Errore invio parola: ${failure.message}")),
      (_) {
        // Stream will update the state
      },
    );
  }

  // ------------------ ON PAUSE GAME TRIGGERED ------------------ //
  Future<void> _onPauseGameTriggered(
      PauseGameTriggered event, Emitter<WordBombState> emit) async {
    if (state is WordBombSessionState &&
        (state as WordBombSessionState).session.status ==
            GameStatus.inProgress &&
        !(state as WordBombSessionState).gameState.isPaused) {
      final currentSessionState = state as WordBombSessionState;

      if (currentSessionState is WordBombAwaitingConfirmation) {
        // Game is already paused awaiting confirmation for a strategic action.
        // General pause shouldn't override this. UI should prevent this.
        // Optionally, emit an error if this state is somehow reached.
        // For now, just return to avoid disrupting the confirmation flow.
        return;
      }
      _roundTimer?.cancel();

      final newGameState = currentSessionState.gameState.copyWith(
        isPaused: true,
        pauseTimeEpochMs: DateTime.now().millisecondsSinceEpoch,
      );
      final result = await _updateGameState(UpdateGameStateParams(
        sessionId: currentSessionState.session.id,
        newGameState:
            WordBombGameStateModelExtension.fromEntity(newGameState).toJson(),
        status: GameStatus.paused,
      ));
      result.fold(
          (failure) =>
              emit(WordBombError("Errore pausa gioco: ${failure.message}")),
          (_) => null // Stream will update
          );
    }
  }

  // ------------------ ON RESUME GAME TRIGGERED ------------------ //
  Future<void> _onResumeGameTriggered(
      ResumeGameTriggered event, Emitter<WordBombState> emit) async {
    if (state is WordBombSessionState &&
        (state as WordBombSessionState).gameState.isPaused) {
      final currentSessionState = state as WordBombSessionState;
      final session = currentSessionState.session;
      final gameState = currentSessionState.gameState;

      if (currentSessionState is WordBombAwaitingConfirmation) {
        // Game is paused awaiting confirmation for a strategic action.
        // General resume shouldn't override this. User must confirm/cancel the action.
        // UI should prevent this.
        // Optionally, emit an error if this state is somehow reached.
        // For now, just return.
        return;
      }

      // Allow admin or current turn player to resume
      if (!_isAdmin(session) && session.currentTurnUserId != _currentUser?.id) {
        if (currentSessionState is WordBombGameActive) {
          emit(currentSessionState.copyWith(
              errorMessage:
                  "Solo l'admin o il giocatore di turno possono riprendere.",
              clearErrorMessage: false));
        } else if (currentSessionState is WordBombPaused) {
          // Need a way to show error on WordBombPaused, or transition to WordBombGameActive with error
          // For now, just log or ignore for WordBombPaused if not admin/current player
        }
        return;
      }

      WordBombGameState newGameState;
      if (gameState.pauseTimeEpochMs != null) {
        final durationOfThisPause =
            DateTime.now().millisecondsSinceEpoch - gameState.pauseTimeEpochMs!;
        final newAccumulatedPausedTime =
            gameState.timeAccumulatedWhilePausedMs + durationOfThisPause;
        newGameState = gameState.copyWith(
          isPaused: false,
          pauseTimeEpochMs:
              null, // Important: clearPauseTimeEpochMs: true if using that pattern
          clearPauseTimeEpochMs: true,
          timeAccumulatedWhilePausedMs: newAccumulatedPausedTime,
        );
      } else {
        // Fallback if pauseTimeEpochMs was null, just unpause
        newGameState = gameState.copyWith(isPaused: false);
      }

      final result = await _updateGameState(UpdateGameStateParams(
        sessionId: session.id,
        newGameState:
            WordBombGameStateModelExtension.fromEntity(newGameState).toJson(),
        status: GameStatus.inProgress,
      ));
      result.fold(
          (failure) =>
              emit(WordBombError("Errore ripresa gioco: ${failure.message}")),
          (_) => null // Stream will update
          );
    }
  }

  // ------------------ ON NEXT PLAYER TURN REQUESTED ------------------ //
  Future<void> _onNextPlayerTurnRequested(
      NextPlayerTurnRequested event, Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive) return;
    final currentActiveState = state as WordBombGameActive;
    final currentSession = currentActiveState.session;
    final currentGameState = currentActiveState.gameState;

    if (!_isAdmin(currentSession)) {
      emit(currentActiveState.copyWith(
          errorMessage: "Solo l'admin può saltare il turno.",
          clearErrorMessage: false));
      return;
    }
    if (_currentPlayersList.isEmpty) {
      emit(currentActiveState.copyWith(
          errorMessage: "Nessun giocatore presente per saltare il turno.",
          clearErrorMessage: false));
      return;
    }

    // Timer is collective: DO NOT cancel _roundTimer here.
    final nextPlayerId = _getNextPlayerId(
        currentSession.currentTurnUserId!, _currentPlayersList);
    // Timer fields are NOT changed here.
    final updatedGameState = currentGameState.copyWith(
      isPaused: false,
    );

    final result = await _updateGameState(
      UpdateGameStateParams(
        sessionId: currentSession.id,
        newGameState:
            WordBombGameStateModelExtension.fromEntity(updatedGameState)
                .toJson(),
        currentTurnUserId: nextPlayerId,
      ),
    );
    result.fold(
      (failure) => emit(
          WordBombError("Errore nel saltare il turno: ${failure.message}")),
      (_) {}, // Stream will update
    );
  }

  // ------------------ ON ACTIVATE TRIAL REQUESTED ------------------ //
  Future<void> _onActivateTrialRequested(
      ActivateTrialRequested event, Emitter<WordBombState> emit) async {
    final user = _currentUser;
    if (user == null) {
      if (state is WordBombGameActive) {
        emit((state as WordBombGameActive).copyWith(
            errorMessage: "Utente non trovato.", clearErrorMessage: false));
      } else {
        emit(const WordBombError("Utente non trovato."));
      }
      return;
    }
    final result = await _setWordBombTrialStatus(
        SetWordBombTrialStatusParams(userId: user.id, isActive: true));
    result.fold(
      (failure) {
        if (state is WordBombGameActive) {
          emit((state as WordBombGameActive).copyWith(
              errorMessage: "Errore attivazione trial: ${failure.message}",
              clearErrorMessage: false));
        } else {
          emit(WordBombError("Errore attivazione trial: ${failure.message}"));
        }
      },
      (success) {
        if (state is WordBombGameActive) {
          emit((state as WordBombGameActive).copyWith(
              errorMessage: "Trial attivato!", clearErrorMessage: false));
        }
      },
    );
  }

  // ------------------ ON REQUEST STRATEGIC ACTION ------------------ //
  Future<void> _onRequestStrategicAction(
      RequestStrategicAction event, Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive) {
      // If already in WordBombAwaitingConfirmation or WordBombPaused, this action might be invalid.
      // WordBombGameActive is the expected state to initiate a new strategic action.
      if (state is WordBombSessionState) {
        final sessionState = state as WordBombSessionState;
        if (sessionState.gameState.isPaused &&
            sessionState is WordBombGameActive) {
          emit(sessionState.copyWith(
              errorMessage: "Il gioco è già in pausa o un'azione è in attesa.",
              clearErrorMessage: false));
          return;
        } else if (sessionState.gameState.isPaused) {
          // Cannot emit error message on other paused states directly. UI should prevent.
          return;
        }
      } else {
        return;
      }
    }
    // Ensure state is WordBombGameActive before proceeding
    final activeState = state as WordBombGameActive;
    final gameState = activeState.gameState;
    final session = activeState.session;
    final currentUser = _currentUser;

    if (currentUser == null || session.currentTurnUserId != currentUser.id) {
      emit(activeState.copyWith(
          errorMessage: "Non è il tuo turno per questa azione.",
          clearErrorMessage: false));
      return;
    }
    if (gameState.isPaused) {
      emit(activeState.copyWith(
          errorMessage: "Il gioco è in pausa.", clearErrorMessage: false));
      return;
    }

    GamePlayer? gamePlayer;
    if (event.actionType == WordBombStrategicActionType.changeCategory) {
      gamePlayer = _currentPlayersList.firstWhere(
          (p) => p.userId == currentUser.id,
          orElse: () =>
              throw Exception("Player not found for change category"));
      if (gamePlayer.changeCategoryUsesLeft <= 0) {
        emit(activeState.copyWith(
            errorMessage: "Non hai più cambi categoria.",
            clearErrorMessage: false));
        return;
      }
    } else if (event.actionType == WordBombStrategicActionType.buyTime) {
      if (gameState.buyTimeUsesLeftForRound <= 0) {
        emit(activeState.copyWith(
            errorMessage: "Non ci sono più 'compra tempo' per il round.",
            clearErrorMessage: false));
        return;
      }
    }

    _roundTimer?.cancel();

    final pendingActionGameState = gameState.copyWith(
      isPaused: true,
      pauseTimeEpochMs: DateTime.now().millisecondsSinceEpoch,
    );

    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: session.id,
      newGameState:
          WordBombGameStateModelExtension.fromEntity(pendingActionGameState)
              .toJson(),
      status: GameStatus.paused,
    ));

    result.fold(
      (failure) => emit(activeState.copyWith(
          // This is WordBombGameActive.copyWith
          errorMessage: "Errore richiesta azione: ${failure.message}",
          clearErrorMessage: false)),
      (updatedSession) {
        emit(WordBombAwaitingConfirmation(
          session: updatedSession,
          players: _currentPlayersList,
          gameState: WordBombGameStateModel.fromJson(updatedSession.gameState!),
          isAdmin: activeState.isAdmin,
          currentPlayerName: _getPlayerName(
              updatedSession.currentTurnUserId, _currentPlayersList),
          actionBeingConfirmed: event.actionType,
        ));
      },
    );
  }

  Future<void> _onConfirmStrategicAction(
      ConfirmStrategicAction event, Emitter<WordBombState> emit) async {
    if (state is! WordBombAwaitingConfirmation) {
      // If not in awaiting confirmation, this event is unexpected.
      // Could emit an error or just return.
      if (state is WordBombGameActive) {
        emit((state as WordBombGameActive).copyWith(
            errorMessage: "Nessuna azione da confermare.",
            clearErrorMessage: false));
      }
      return;
    }
    _isProcessingStrategicActionConfirmation = true;
    try {
      final awaitingState = state as WordBombAwaitingConfirmation;
      final actionToPerform = awaitingState.actionBeingConfirmed;
      final pausedGameState = awaitingState.gameState;
      final session = awaitingState.session;
      final currentUser = _currentUser!;

      if (pausedGameState.pauseTimeEpochMs == null) {
        // This should not happen if we are in WordBombAwaitingConfirmation
        // which implies the game was paused correctly.
        // Revert to active state with an error.
        final errorState = WordBombGameActive(
            session: session,
            players: _currentPlayersList,
            gameState: pausedGameState.copyWith(
                isPaused: false, clearPauseTimeEpochMs: true),
            isAdmin: awaitingState.isAdmin,
            currentPlayerName: awaitingState.currentPlayerName,
            currentUserId: currentUser.id,
            errorMessage: "Errore interno: stato di pausa non valido.");
        emit(errorState);
        // also update DB to unpause
        _updateGameState(UpdateGameStateParams(
          sessionId: session.id,
          newGameState: WordBombGameStateModelExtension.fromEntity(
                  pausedGameState.copyWith(
                      isPaused: false, clearPauseTimeEpochMs: true))
              .toJson(),
          status: GameStatus.inProgress,
        ));
        return;
      }

      final durationOfThisPause = DateTime.now().millisecondsSinceEpoch -
          pausedGameState.pauseTimeEpochMs!;
      final newAccumulatedPausedTime =
          pausedGameState.timeAccumulatedWhilePausedMs + durationOfThisPause;

      WordBombGameState resumedStateCore = pausedGameState.copyWith(
        isPaused: false,
        clearPauseTimeEpochMs: true,
        timeAccumulatedWhilePausedMs: newAccumulatedPausedTime,
      );

      WordBombGameState finalGameState;

      if (actionToPerform == WordBombStrategicActionType.buyTime) {
        final newTotalDuration =
            resumedStateCore.currentTurnTotalDurationMs + _buyTimeBonusMs;
        finalGameState = resumedStateCore.copyWith(
          currentTurnTotalDurationMs: newTotalDuration,
          buyTimeUsesLeftForRound: resumedStateCore.buyTimeUsesLeftForRound - 1,
        );
        // No player update needed for buyTime uses as it's on gameState
      } else if (actionToPerform ==
          WordBombStrategicActionType.changeCategory) {
        GamePlayer gamePlayer =
            _currentPlayersList.firstWhere((p) => p.userId == currentUser.id);

        final playerUpdateResult =
            await _updateGamePlayer(UpdateGamePlayerParams(
          playerId: gamePlayer.id,
          sessionId: session.id,
          userId: currentUser.id,
          changeCategoryUsesLeft: gamePlayer.changeCategoryUsesLeft - 1,
        ));

        bool playerUpdateFailed = false;
        await playerUpdateResult.fold((failure) async {
          playerUpdateFailed = true;
          emit(WordBombGameActive(
            session: session,
            players: _currentPlayersList,
            gameState: resumedStateCore.copyWith(
                isPaused: true,
                pauseTimeEpochMs: DateTime.now().millisecondsSinceEpoch),
            isAdmin: awaitingState.isAdmin,
            currentPlayerName: awaitingState.currentPlayerName,
            currentUserId: currentUser.id,
            errorMessage:
                "Errore aggiornamento usi cambio categoria: ${failure.message}",
          ));
          // Update DB to reflect a paused state since the action failed mid-way
          // but after the initial pause for confirmation.
          // Or, revert to resumedStateCore if that's safer. For now, re-pause.
          await _updateGameState(UpdateGameStateParams(
            sessionId: session.id,
            newGameState: WordBombGameStateModelExtension.fromEntity(
                    resumedStateCore.copyWith(
                        isPaused: true,
                        pauseTimeEpochMs:
                            DateTime.now().millisecondsSinceEpoch))
                .toJson(),
            status: GameStatus.paused,
          ));
        }, (updatedPlayer) {
          _currentPlayersList = _currentPlayersList
              .map((p) => p.id == updatedPlayer.id ? updatedPlayer : p)
              .toList();
        });

        if (playerUpdateFailed) return;

        final newCategory = _categories[Random().nextInt(_categories.length)];
        final newLetter = GameConstants
            .alphabet[Random().nextInt(GameConstants.alphabet.length)];
        finalGameState = resumedStateCore.copyWith(
          currentCategory: newCategory,
          currentLetterSyllable: newLetter,
          usedWords: [], // Reset used words
          // DO NOT CHANGE: roundStartTimeEpochMs, currentTurnTotalDurationMs
          // isPaused, pauseTimeEpochMs, timeAccumulatedWhilePausedMs are handled by resumedStateCore
          isGhostProtocolActive: false, // Reset ghost protocol if it was active
        );
      } else {
        // Should not happen
        finalGameState = resumedStateCore;
      }

      final result = await _updateGameState(UpdateGameStateParams(
        sessionId: session.id,
        newGameState:
            WordBombGameStateModelExtension.fromEntity(finalGameState).toJson(),
        status: GameStatus.inProgress, // Resume game
      ));

      result.fold(
        (failure) {
          emit(WordBombGameActive(
            session: session,
            players: _currentPlayersList,
            gameState: finalGameState.copyWith(
                isPaused: true,
                pauseTimeEpochMs: DateTime.now().millisecondsSinceEpoch),
            isAdmin: awaitingState.isAdmin,
            currentPlayerName: awaitingState.currentPlayerName,
            currentUserId: currentUser.id,
            errorMessage: "Errore esecuzione azione: ${failure.message}",
          ));
        },
        (updatedSessionFromDb) {
          // Optimistically emit WordBombGameActive
          emit(WordBombGameActive(
            session: updatedSessionFromDb,
            players: _currentPlayersList,
            gameState: WordBombGameStateModel.fromJson(
                updatedSessionFromDb.gameState!),
            isAdmin: _isAdmin(updatedSessionFromDb),
            currentPlayerName: _getPlayerName(
                updatedSessionFromDb.currentTurnUserId, _currentPlayersList),
            currentUserId: currentUser.id,
          ));
          // Stream will eventually confirm this state or a subsequent one.
        },
      );
    } finally {
      _isProcessingStrategicActionConfirmation = false;
    }
  }

  Future<void> _onCancelStrategicAction(
      CancelStrategicAction event, Emitter<WordBombState> emit) async {
    if (state is! WordBombAwaitingConfirmation) {
      if (state is WordBombGameActive) {
        emit((state as WordBombGameActive).copyWith(
            errorMessage: "Nessuna azione da annullare.",
            clearErrorMessage: false));
      }
      return;
    }
    _isProcessingStrategicActionConfirmation = true;
    try {
      final awaitingState = state as WordBombAwaitingConfirmation;
      final pausedGameState = awaitingState.gameState;
      final session = awaitingState.session;

      if (pausedGameState.pauseTimeEpochMs == null) {
        // Should not happen, similar to _onConfirmStrategicAction
        // Attempt to recover by unpausing.
        await _updateGameState(UpdateGameStateParams(
          sessionId: session.id,
          newGameState: WordBombGameStateModelExtension.fromEntity(
                  pausedGameState.copyWith(
                      isPaused: false, clearPauseTimeEpochMs: true))
              .toJson(),
          status: GameStatus.inProgress,
        ));
        // Stream will handle the state update.
        return;
      }

      final durationOfThisPause = DateTime.now().millisecondsSinceEpoch -
          pausedGameState.pauseTimeEpochMs!;
      final newAccumulatedPausedTime =
          pausedGameState.timeAccumulatedWhilePausedMs + durationOfThisPause;

      final finalGameState = pausedGameState.copyWith(
        isPaused: false,
        clearPauseTimeEpochMs: true,
        timeAccumulatedWhilePausedMs: newAccumulatedPausedTime,
      );

      final result = await _updateGameState(UpdateGameStateParams(
        sessionId: session.id,
        newGameState:
            WordBombGameStateModelExtension.fromEntity(finalGameState).toJson(),
        status: GameStatus.inProgress,
      ));

      result.fold((failure) {
        emit(WordBombGameActive(
          session: session,
          players: _currentPlayersList,
          gameState: finalGameState.copyWith(
              isPaused: true,
              pauseTimeEpochMs: DateTime.now().millisecondsSinceEpoch),
          isAdmin: awaitingState.isAdmin,
          currentPlayerName: awaitingState.currentPlayerName,
          currentUserId: _currentUser?.id,
          errorMessage: "Errore annullamento azione: ${failure.message}",
        ));
      }, (updatedSessionFromDb) {
        // Optimistically emit WordBombGameActive
        emit(WordBombGameActive(
          session: updatedSessionFromDb,
          players: _currentPlayersList,
          gameState:
              WordBombGameStateModel.fromJson(updatedSessionFromDb.gameState!),
          isAdmin: _isAdmin(updatedSessionFromDb),
          currentPlayerName: _getPlayerName(
              updatedSessionFromDb.currentTurnUserId, _currentPlayersList),
          currentUserId: _currentUser?.id,
        ));
        // Stream will eventually confirm this state or a subsequent one.
      });
    } finally {
      _isProcessingStrategicActionConfirmation = false;
    }
  }

  // ------------------ ON CLEAR WORD BOMB ERROR MESSAGE ------------------ //
  void _onClearWordBombErrorMessage(
      ClearWordBombErrorMessage event, Emitter<WordBombState> emit) {
    if (state is WordBombGameActive) {
      final activeState = state as WordBombGameActive;
      if (activeState.errorMessage != null) {
        emit(activeState.copyWith(clearErrorMessage: true));
      }
    }
  }

  // ------------------ ON PLAYER EXPLODED ------------------ //
  Future<void> _onPlayerExploded(
      PlayerExploded event, Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive) return;
    final activeState = state as WordBombGameActive;
    final session = activeState.session;
    final gameState = activeState.gameState;

    // Ensure the player exploding is the current turn player and timer is up, or admin forces it.
    // For now, we assume the event is valid.
    _roundTimer?.cancel();

    final newGameState = gameState.copyWith(
      playerWhoExplodedId: event.playerId,
      isPaused: true, // Pause the game flow until next round starts
      pauseTimeEpochMs: DateTime.now().millisecondsSinceEpoch,
    );

    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: session.id,
      newGameState:
          WordBombGameStateModelExtension.fromEntity(newGameState).toJson(),
      // Status could remain inProgress or go to paused, depending on desired flow.
      // Let's keep it inProgress but gameState.isPaused handles the timer.
      // Or, explicitly set to paused to reflect the state.
      status: GameStatus.paused,
    ));

    result.fold(
      (failure) => emit(activeState.copyWith(
          errorMessage: "Errore esplosione giocatore: ${failure.message}",
          clearErrorMessage: false)),
      (_) {
        // Stream will update to WordBombPlayerExploded state via _emitStateFromSession
      },
    );
  }

  // ------------------ ON PLAYER ACCEPTED DEFEAT ------------------ //
  Future<void> _onPlayerAcceptedDefeat(
      PlayerAcceptedDefeat event, Emitter<WordBombState> emit) async {
    if (state is! WordBombPlayerExploded) return;

    final explodedState = state as WordBombPlayerExploded;
    final session = explodedState.session;
    final gameState = explodedState.gameState;
    final explodedPlayerId = gameState.playerWhoExplodedId;

    if (explodedPlayerId == null) {
      // Should not happen if in WordBombPlayerExploded state
      if (state is WordBombGameActive) {
        emit((state as WordBombGameActive).copyWith(
            errorMessage: "Nessun giocatore esploso da processare.",
            clearErrorMessage: false));
      }
      return;
    }

    // Only admin can trigger the next round start after defeat is accepted.
    // The "PlayerAcceptedDefeat" event is more of a signal from the client.
    // The actual round restart logic is handled by admin.
    // If the current user is the admin, they can re-initialize the round.
    if (_isAdmin(session)) {
      // Admin can now start a new round, typically with the exploded player going first.
      await _adminInitializeNewRound(session, emit,
          startingPlayerId: explodedPlayerId);
    } else {
      // Non-admins just wait. The UI might change to "Waiting for admin to start next round".
      // No specific state change needed here from BLoC for non-admins,
      // they remain in WordBombPlayerExploded until admin acts.
      // Optionally, emit the same state to refresh UI if needed, but stream should handle it.
      emit(explodedState.copyWith());
    }
  }

  // ------------------ ON ACTIVATE GHOST PROTOCOL REQUESTED ------------------ //
  Future<void> _onActivateGhostProtocolRequested(
      ActivateGhostProtocolRequested event, Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive) return;
    final activeState = state as WordBombGameActive;
    final session = activeState.session;
    final gameState = activeState.gameState;
    final currentUser = _currentUser;

    if (currentUser == null ||
        // session.currentTurnUserId != currentUser.id || // Removed this check
        gameState.ghostPlayerId != currentUser.id) {
      emit(activeState.copyWith(
          errorMessage: "Non puoi attivare il Protocollo Fantasma.",
          clearErrorMessage: false));
      return;
    }

    GamePlayer? ghostPlayer = _currentPlayersList
        .firstWhere((p) => p.userId == gameState.ghostPlayerId);
    if (ghostPlayer.hasUsedGhostProtocol) {
      emit(activeState.copyWith(
          errorMessage: "Protocollo Fantasma già usato.",
          clearErrorMessage: false));
      return;
    }

    final playerUpdateResult = await _updateGamePlayer(UpdateGamePlayerParams(
      playerId: ghostPlayer.id,
      sessionId: session.id,
      userId: ghostPlayer.userId,
      hasUsedGhostProtocol: true,
    ));

    bool playerUpdateFailed = false;
    playerUpdateResult.fold(
      (failure) {
        playerUpdateFailed = true;
        emit(activeState.copyWith(
            errorMessage:
                "Errore attivazione Protocollo Fantasma: ${failure.message}",
            clearErrorMessage: false));
      },
      (updatedPlayer) {
        _currentPlayersList = _currentPlayersList
            .map((p) => p.id == updatedPlayer.id ? updatedPlayer : p)
            .toList();
      },
    );

    if (playerUpdateFailed) return;

    final newGameState = gameState.copyWith(
      isGhostProtocolActive: true,
      ghostProtocolActivationTimeEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: session.id,
      newGameState:
          WordBombGameStateModelExtension.fromEntity(newGameState).toJson(),
    ));

    result.fold(
      (failure) => emit(activeState.copyWith(
          errorMessage:
              "Errore aggiornamento stato gioco per Protocollo Fantasma: ${failure.message}",
          clearErrorMessage: false)),
      (_) {
        // Stream will update
      },
    );
  }

  Future<void> _onDeactivateGhostProtocolDueToTimeout(
      DeactivateGhostProtocolDueToTimeout event,
      Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive) return;
    final activeState = state as WordBombGameActive;
    final session = activeState.session;
    final gameState = activeState.gameState;

    // Ensure it's still active and the current user is the ghost (or admin could force it)
    if (!gameState.isGhostProtocolActive ||
        gameState.ghostPlayerId != _currentUser?.id) {
      // Silently return if not applicable, or if already deactivated by another means.
      return;
    }

    final newGameState = gameState.copyWith(
      isGhostProtocolActive: false,
      clearGhostProtocolActivationTimeEpochMs: true,
    );

    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: session.id,
      newGameState:
          WordBombGameStateModelExtension.fromEntity(newGameState).toJson(),
    ));

    result.fold(
      (failure) => emit(activeState.copyWith(
          errorMessage:
              "Errore disattivazione Protocollo Fantasma: ${failure.message}",
          clearErrorMessage: false)),
      (_) {
        // Stream will update
      },
    );
  }

  // ------------------ ON CHALLENGE INITIATED ------------------ //
  Future<void> _onChallengeInitiated(
      ChallengeInitiated event, Emitter<WordBombState> emit) async {
    // Placeholder: Implement challenge logic
    // This might involve pausing the game, setting a "challenge active" state,
    // and allowing players to vote or an admin to adjudicate.
    if (state is WordBombGameActive) {
      final activeState = state as WordBombGameActive;
      // For now, just emit an informational message or a specific challenge state if defined.
      emit(activeState.copyWith(
          errorMessage: "Funzionalità di sfida non ancora implementata.",
          clearErrorMessage: false));
    }
  }

  // Removed _onChangeCategoryRequested and _onBuyTimeRequested as their logic
  // is now part of _onConfirmStrategicAction.
  // Ensure all calls to them are replaced by RequestStrategicAction.

  // =====================================================================
  // INTERNAL EVENT HANDLERS / STREAM UPDATERS
  // =====================================================================

  // ------------------ ON WORD BOMB GAME STATE UPDATED ------------------ //
  void _onWordBombGameStateUpdated(
      _WordBombGameStateUpdated event, Emitter<WordBombState> emit) {
    _emitStateFromSession(event.session, _currentPlayersList, emit);
  }

  // ------------------ ON TIMER TICK ------------------ //
  void _onTimerTick(_TimerTick event, Emitter<WordBombState> emit) {
    if (state is WordBombGameActive) {
      final activeState = state as WordBombGameActive;
      final gameState = activeState.gameState;

      if (gameState.isPaused) {
        _roundTimer?.cancel();
        return;
      }

      if (gameState.playerWhoExplodedId != null) {
        _roundTimer?.cancel();
        return;
      }

      // Check for Ghost Protocol timeout
      if (gameState.isGhostProtocolActive &&
          gameState.ghostPlayerId == _currentUser?.id &&
          activeState.session.currentTurnUserId == _currentUser?.id &&
          gameState.ghostProtocolActivationTimeEpochMs != null) {
        final elapsedSinceGhostActivation =
            DateTime.now().millisecondsSinceEpoch -
                gameState.ghostProtocolActivationTimeEpochMs!;
        if (elapsedSinceGhostActivation >= 30000) {
          // 30 seconds
          add(const DeactivateGhostProtocolDueToTimeout());
          // Note: The timer tick for explosion check below will still run this iteration.
          // Deactivation will take effect on next state update.
        }
      }

      if (activeState.session.currentTurnUserId == _currentUser?.id &&
          gameState.calculatedRemainingTimeMs <= 0) {
        _roundTimer?.cancel();
        add(PlayerExploded(activeState.session.currentTurnUserId!));
      }
    } else {
      _roundTimer?.cancel();
    }
  }

  // ------------------ ON ERROR OCCURRED ------------------ //
  void _onErrorOccurred(
      _WordBombErrorOccurred event, Emitter<WordBombState> emit) {
    if (state is WordBombSessionState) {
      final currentSessionState = state as WordBombSessionState;
      if (currentSessionState is WordBombGameActive) {
        emit(currentSessionState.copyWith(
            errorMessage: event.message, clearErrorMessage: false));
      } else {
        emit(WordBombError(event.message));
      }
    } else {
      emit(WordBombError(event.message));
    }
  }

  // =====================================================================
  // UTILITY METHODS
  // =====================================================================

  // ------------------ ADMIN INITIALIZE NEW ROUND ------------------ //
  Future<void> _adminInitializeNewRound(
      GameSession session, Emitter<WordBombState> emit,
      {String? startingPlayerId}) async {
    emit(WordBombLoading());
    if (_currentPlayersList.isEmpty) {
      emit(WordBombError(
          "Impossibile iniziare il round: nessun giocatore attivo."));
      return;
    }

    String? ghostPlayerId;
    if (_currentPlayersList.length >= 2) {
      // Ghost only if 2+ players
      ghostPlayerId =
          _currentPlayersList[Random().nextInt(_currentPlayersList.length)]
              .userId;
    }

    final newGameState = _createNewRoundGameState(ghostPlayerId: ghostPlayerId);
    final nextPlayerId = startingPlayerId ??
        _getNextPlayerId(session.currentTurnUserId, _currentPlayersList, true);

    final gameStateUpdateResult = await _updateGameState(
      UpdateGameStateParams(
        sessionId: session.id,
        newGameState:
            WordBombGameStateModelExtension.fromEntity(newGameState).toJson(),
        currentTurnUserId: nextPlayerId,
        status: GameStatus.inProgress,
      ),
    );

    await gameStateUpdateResult.fold(
      (failure) async => emit(
          WordBombError("Errore inizializzazione round: ${failure.message}")),
      (updatedSession) async {
        // After successfully setting the new round state, reset player powers
        final List<Future<void>> playerResetFutures = [];
        for (final player in _currentPlayersList) {
          playerResetFutures.add(
            _updateGamePlayer(UpdateGamePlayerParams(
              playerId: player.id,
              sessionId: session.id,
              userId: player.userId,
              hasUsedGhostProtocol: false,
              changeCategoryUsesLeft: GamePlayer.defaultChangeCategoryUses,
            )),
          );
        }
      },
    );
  }

  // ------------------ CREATE NEW ROUND GAME STATE ------------------ //
  WordBombGameState _createNewRoundGameState({String? ghostPlayerId}) {
    final randomCategory = _categories.isNotEmpty
        ? _categories[Random().nextInt(_categories.length)]
        : "Oggetti";

    final randomLetter =
        GameConstants.alphabet[Random().nextInt(GameConstants.alphabet.length)];

    return WordBombGameState(
      currentCategory: randomCategory,
      currentLetterSyllable: randomLetter,
      usedWords: const [],
      currentTurnTotalDurationMs: _wordBombRoundDurationMs,
      roundStartTimeEpochMs: DateTime.now().millisecondsSinceEpoch,
      isPaused: false,
      ghostPlayerId: ghostPlayerId,
      isGhostProtocolActive: false,
      buyTimeUsesLeftForRound: 3,
      pauseTimeEpochMs: null,
      timeAccumulatedWhilePausedMs: 0,
      ghostProtocolActivationTimeEpochMs: null,
    );
  }

  // ------------------ START STREAMS ------------------ //
  void _startStreams(String sessionId, Emitter<WordBombState> emit) {
    _cancelSubscriptions();
    _sessionSubscription = _streamGameSession(sessionId).listen(
      (eitherSession) => eitherSession.fold(
        (failure) {
          add(_WordBombErrorOccurred(
              'Errore stream sessione: ${failure.message}'));
        },
        (session) {
          add(_WordBombGameStateUpdated(session));
        },
      ),
      onError: (error) => add(
          _WordBombErrorOccurred('Errore stream sessione (onError): $error')),
    );

    _playersSubscription = _streamLobbyPlayers(sessionId).listen(
      (eitherPlayers) => eitherPlayers.fold(
        (failure) {
          add(_WordBombErrorOccurred(
              'Errore stream giocatori: ${failure.message}'));
        },
        (players) {
          _currentPlayersList = players;
          // If state is already a session state, re-emit with new players
          if (state is WordBombSessionState) {
            final currentSessionState = state as WordBombSessionState;
            // Trigger re-evaluation of state with new players
            add(_WordBombGameStateUpdated(currentSessionState.session));
          }
        },
      ),
      onError: (error) => add(
          _WordBombErrorOccurred('Errore stream giocatori (onError): $error')),
    );
  }

  // ------------------ EMIT STATE FROM SESSION ------------------ //
  void _emitStateFromSession(GameSession session, List<GamePlayer> players,
      Emitter<WordBombState> emit) {
    if (isClosed) return; // Guard

    if (session.status == GameStatus.finished) {
      _cancelSubscriptions();
      emit(WordBombInitial());
      return;
    }

    if (session.gameState == null) {
      if (session.status == GameStatus.waiting) {
        if (isClosed) return;
        emit(WordBombLoading());
        return;
      }

      if (session.status == GameStatus.inProgress) {
        // Game is inProgress, but no gameState yet.
        if (_isAdmin(session)) {
          // Admin's BLoC:
          // If it's Initial/Loading, _onInitializeWordBombGame handles calling _adminInitializeNewRound.
          // If admin's BLoC is in another state (e.g. Error) and gameState is null, it's an issue.
          if (state is WordBombInitial || state is WordBombLoading) {
            // Admin is still initializing. _onInitializeWordBombGame is responsible.
            // Emit Loading to ensure UI reflects this phase.
            if (isClosed) return;
            emit(WordBombLoading());
            return;
          } else {
            // Admin's BLoC is in a non-Initial/Loading state (e.g. Error, or an unexpected active state)
            // and gameState is null. This is an error for the admin.
            if (isClosed) return;
            emit(WordBombError(
                "Stato del gioco non disponibile (Admin). L'admin potrebbe dover (ri)avviare il round."));
            return;
          }
        } else {
          // Non-admin
          // Non-admin: should show Loading until gameState is available.
          // Even if they were in a temporary error state from another stream,
          // prioritize showing Loading if the game is inProgress and gameState is missing.
          if (isClosed) return;
          emit(WordBombLoading());
          return;
        }
      }

      // Fallback for other statuses if gameState is null (e.g., unexpected status)
      if (isClosed) return;
      emit(WordBombError(
          "Stato del gioco inatteso (${session.status}) o mancante."));
      return;
    }

    try {
      final wordBombGameState =
          WordBombGameStateModel.fromJson(session.gameState!);

      final isAdmin = _isAdmin(session);
      final currentPlayerName =
          _getPlayerName(session.currentTurnUserId, players);
      final currentUserId = _currentUser?.id;

      if (wordBombGameState.playerWhoExplodedId != null) {
        emit(WordBombPlayerExploded(
          session: session,
          players: players,
          gameState: wordBombGameState,
          isAdmin: isAdmin,
          currentPlayerName: currentPlayerName,
          explodedPlayerId: wordBombGameState.playerWhoExplodedId!,
        ));
      } else if (wordBombGameState.isPaused) {
        // Stream indicates game is paused.

        // If we are currently processing a strategic action confirmation,
        // and the BLoC has already optimistically emitted WordBombGameActive (unpaused),
        // then this incoming stream event (saying isPaused=true) is stale regarding the pause status.
        // We should honor the optimistic unpaused state.
        if (_isProcessingStrategicActionConfirmation &&
            state is WordBombGameActive) {
          final optimisticActiveState = state as WordBombGameActive;
          // Re-emit the optimistic state, but update session and players from the stream.
          // The gameState (especially isPaused=false) from optimisticActiveState is preserved.
          emit(WordBombGameActive(
              session: session,
              players: players,
              gameState: optimisticActiveState.gameState,
              isAdmin: _isAdmin(session),
              currentPlayerName:
                  _getPlayerName(session.currentTurnUserId, players),
              currentUserId: optimisticActiveState.currentUserId,
              errorMessage: optimisticActiveState.errorMessage));
          return;
        }

        // If the BLoC is in WordBombAwaitingConfirmation state, and this stream event's pause
        // matches the pause initiated for that confirmation, then update the WordBombAwaitingConfirmation state.
        if (state is WordBombAwaitingConfirmation) {
          final awaitingState = state as WordBombAwaitingConfirmation;
          if (awaitingState.gameState.pauseTimeEpochMs != null &&
              awaitingState.gameState.pauseTimeEpochMs ==
                  wordBombGameState.pauseTimeEpochMs) {
            emit(awaitingState.copyWith(
                session: session,
                players: players,
                gameState: wordBombGameState,
                isAdmin: _isAdmin(session),
                currentPlayerName:
                    _getPlayerName(session.currentTurnUserId, players)));
            return;
          }
        }

        // Otherwise, it's a general pause (e.g., admin paused, or a new pause not related to current confirmation flow)
        emit(WordBombPaused(
          session: session,
          players: players,
          gameState: wordBombGameState,
          isAdmin: isAdmin,
          currentPlayerName: currentPlayerName,
        ));
      } else {
        // Game is not paused
        final activeState = WordBombGameActive(
          session: session,
          players: players,
          gameState: wordBombGameState,
          isAdmin: isAdmin,
          currentPlayerName: currentPlayerName,
          currentUserId: currentUserId,
          errorMessage: (state is WordBombGameActive &&
                  (state as WordBombGameActive).session.id == session.id)
              ? (state as WordBombGameActive).errorMessage
              : null,
        );
        emit(activeState);
        if (session.currentTurnUserId == currentUserId &&
            !wordBombGameState.isPaused) {
          _startRoundTimer(emit);
        } else {
          _roundTimer?.cancel();
        }
      }
    } catch (e) {
      emit(WordBombError(
          "Errore durante la deserializzazione dello stato del gioco: $e"));
    }
  }

  // ------------------ GET PLAYER NAME ------------------ //
  String? _getPlayerName(String? userId, List<GamePlayer> players) {
    if (userId == null) return null;
    try {
      return players.firstWhere((p) => p.userId == userId).userName;
    } catch (e) {
      return "Sconosciuto";
    }
  }

  // ------------------ GET NEXT PLAYER ID ------------------ //
  String _getNextPlayerId(String? currentUserId, List<GamePlayer> activePlayers,
      [bool isNewRound = false]) {
    if (activePlayers.isEmpty) {
      throw Exception("No active players to determine next turn.");
    }
    if (activePlayers.length == 1) return activePlayers.first.userId;

    if (currentUserId == null || isNewRound) {
      // For new round or if current is null, pick random
      return activePlayers[Random().nextInt(activePlayers.length)].userId;
    }

    final currentIndex =
        activePlayers.indexWhere((p) => p.userId == currentUserId);
    if (currentIndex == -1) {
      // Current player not in list (e.g. left), pick random
      return activePlayers[Random().nextInt(activePlayers.length)].userId;
    }
    return activePlayers[(currentIndex + 1) % activePlayers.length].userId;
  }

  // ------------------ START ROUND TIMER ------------------ //

  void _startRoundTimer(Emitter<WordBombState> emit) {
    // 1. Cancella sempre qualsiasi timer precedente per evitare duplicati.
    _roundTimer?.cancel();

    // 2. Controlla se la piattaforma è iOS.
    if (Platform.isIOS) {
      _roundTimer = Timer(const Duration(milliseconds: 1500), () {
        // a. Il ritardo di 1.5 secondi è terminato. Esegui il primo "tick".
        add(const _TimerTick());

        _roundTimer =
            Timer.periodic(const Duration(milliseconds: _timerIntervalMs), (_) {
          add(
            const _TimerTick(),
          );
        });
      });
    } else {
      // Avvia il timer periodico immediatamente, come nel codice originale.
      _roundTimer =
          Timer.periodic(const Duration(milliseconds: _timerIntervalMs), (_) {
        add(const _TimerTick());
      });
    }
  }

  // ------------------ CANCEL SUBSCRIPTIONS ------------------ //
  void _cancelSubscriptions() {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _playersSubscription?.cancel();
    _playersSubscription = null;
    _roundTimer?.cancel();
    _roundTimer = null;
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
