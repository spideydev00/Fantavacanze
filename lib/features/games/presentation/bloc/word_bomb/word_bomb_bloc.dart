import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart'
    as auth_user;
import 'package:fantavacanze_official/features/games/data/models/word_bomb_game_state_model.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/entities/word_bomb_game_state.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/get_word_bomb_categories.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_lobby_players.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_player.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_state.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';

part 'word_bomb_event.dart';
part 'word_bomb_state.dart';

const int _wordBombTurnDurationMs = 10000; // 10 seconds per turn
const int _timerIntervalMs = 100; // Update UI every 100ms

class WordBombBloc extends Bloc<WordBombEvent, WordBombState> {
  final UpdateGameState _updateGameState;
  final UpdateGamePlayer _updateGamePlayer;
  final GetWordBombCategories _getWordBombCategories;
  final StreamGameSession _streamGameSession;
  final StreamLobbyPlayers _streamLobbyPlayers;
  final AppUserCubit _appUserCubit;

  StreamSubscription<dynamic>? _sessionSubscription;
  StreamSubscription<dynamic>? _playersSubscription;
  Timer? _turnTimer;
  List<String> _categories = [];

  auth_user.User? get _currentUser {
    final userState = _appUserCubit.state;
    if (userState is AppUserIsLoggedIn) {
      return userState.user;
    }
    return null;
  }

  bool _isAdmin(GameSession? session) =>
      session != null && _currentUser?.id == session.adminId;

  WordBombBloc({
    required UpdateGameState updateGameState,
    required UpdateGamePlayer updateGamePlayer,
    required GetWordBombCategories getWordBombCategories,
    required StreamGameSession streamGameSession,
    required StreamLobbyPlayers streamLobbyPlayers,
    required AppUserCubit appUserCubit,
  })  : _updateGameState = updateGameState,
        _updateGamePlayer = updateGamePlayer,
        _getWordBombCategories = getWordBombCategories,
        _streamGameSession = streamGameSession,
        _streamLobbyPlayers = streamLobbyPlayers,
        _appUserCubit = appUserCubit,
        super(WordBombInitial()) {
    on<InitializeWordBombGame>(_onInitializeWordBombGame);
    on<SubmitWord>(_onSubmitWord);
    on<PauseGameTriggered>(_onPauseGameTriggered);
    on<ResumeGameTriggered>(_onResumeGameTriggered);
    on<NextPlayerTurnRequested>(_onNextPlayerTurnRequested);
    on<AssignGhostRole>(_onAssignGhostRole);
    on<_WordBombGameStateUpdated>(_onWordBombGameStateUpdated);
    on<_TimerTick>(_onTimerTick);
    on<_WordBombErrorOccurred>(_onErrorOccurred);
  }

  Future<void> _onInitializeWordBombGame(
      InitializeWordBombGame event, Emitter<WordBombState> emit) async {
    emit(WordBombLoading());

    final categoriesResult = await _getWordBombCategories(NoParams());
    await categoriesResult.fold(
      (failure) async => emit(WordBombError(failure.message)),
      (categories) async {
        _categories = categories;
        _startStreams(event.initialSession.id, emit);

        final playersStream = _streamLobbyPlayers(event.initialSession.id);
        final eitherPlayers = await playersStream.first;

        await eitherPlayers.fold(
            (failure) async => emit(WordBombError(
                "Errore caricamento giocatori: ${failure.message}")),
            (initialPlayers) async {
          if (_isAdmin(event.initialSession) &&
              event.initialSession.gameState == null &&
              initialPlayers.isNotEmpty) {
            // Admin initializes the game state for the first time
            final initialGameState =
                _createInitialWordBombState(initialPlayers);
            final updateResult = await _updateGameState(UpdateGameStateParams(
              sessionId: event.initialSession.id,
              newGameState:
                  WordBombGameStateModelExtension.fromEntity(initialGameState)
                      .toJson(), // Corrected call
              currentTurnUserId:
                  initialPlayers.first.userId, // Start with the first player
              status: GameStatus.inProgress, // Ensure status is inProgress
            ));

            await updateResult.fold(
                (failure) async => emit(WordBombError(
                    "Errore inizializzazione gioco: ${failure.message}")),
                (updatedSession) {
              // The stream will pick up this change.
              // No need to emit here, _onWordBombGameStateUpdated will handle it.
            });
          } else if (event.initialSession.gameState != null) {
            // Game state already exists, just emit ready
            final wbGameState = WordBombGameStateModel.fromJson(
                event.initialSession.gameState!);
            final currentPlayerName = _getPlayerName(
                event.initialSession.currentTurnUserId, initialPlayers);
            emit(WordBombGameActive(
              session: event.initialSession,
              gameState: wbGameState,
              players: initialPlayers,
              isAdmin: _isAdmin(event.initialSession),
              currentPlayerName: currentPlayerName,
            ));
            if (_isAdmin(event.initialSession) && !wbGameState.isPaused) {
              _startTurnTimer(emit);
            }
          } else {
            // Non-admin joins, or admin joins an already initialized game
            // Wait for stream to provide game state
          }
        });
      },
    );
  }

  WordBombGameState _createInitialWordBombState(List<GamePlayer> players) {
    final randomCategory = _categories.isNotEmpty
        ? _categories[Random().nextInt(_categories.length)]
        : "Oggetti";
    final randomLetter =
        String.fromCharCode('A'.codeUnitAt(0) + Random().nextInt(26));

    return WordBombGameState(
      // Return WordBombGameState
      currentCategory: randomCategory,
      currentLetterSyllable: randomLetter,
      usedWords: [],
      remainingTimeMs: _wordBombTurnDurationMs,
      isPaused: false,
      totalTurnTimeMs: _wordBombTurnDurationMs, // Initialize new field
      // ghostPlayerId: ghostId, // Set if ghost assigned here
    );
  }

  Future<void> _onAssignGhostRole(
      AssignGhostRole event, Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive ||
        !_isAdmin((state as WordBombGameActive).session)) {
      return;
    }
    final currentActiveState = state as WordBombGameActive;

    final playerToUpdate = currentActiveState.players.firstWhere(
        (p) => p.id == event.playerIdToGhost,
        orElse: () => throw Exception("Player not found for ghost assignment"));

    final updatePlayerResult = await _updateGamePlayer(UpdateGamePlayerParams(
      playerId: playerToUpdate.id,
      sessionId: currentActiveState.session.id,
      userId: playerToUpdate.userId,
      isGhost: true,
    ));

    updatePlayerResult.fold(
        // Removed await here
        (failure) => emit(
            WordBombError("Errore assegnazione Fantasma: ${failure.message}")),
        (_) async {
      // Also update the ghostPlayerId in the game_state JSONB
      final newGameState = currentActiveState.gameState
          .copyWith(ghostPlayerId: playerToUpdate.userId);
      final updateGameStateResult =
          await _updateGameState(UpdateGameStateParams(
        sessionId: currentActiveState.session.id,
        newGameState: WordBombGameStateModelExtension.fromEntity(newGameState)
            .toJson(), // Corrected call
      ));
      updateGameStateResult.fold(
          (failure) => emit(WordBombError(
              "Errore aggiornamento stato gioco per Fantasma: ${failure.message}")),
          (_) {/* Stream will update */});
    });
  }

  void _startStreams(String sessionId, Emitter<WordBombState> emit) {
    _sessionSubscription?.cancel();
    _sessionSubscription = _streamGameSession(sessionId).listen(
      (eitherSession) => eitherSession.fold(
        (failure) => add(_WordBombErrorOccurred(
            'Errore stream sessione: ${failure.message}')),
        (session) => add(_WordBombGameStateUpdated(session)),
      ),
      onError: (error) =>
          add(_WordBombErrorOccurred('Errore stream sessione: $error')),
    );

    _playersSubscription?.cancel();
    _playersSubscription = _streamLobbyPlayers(sessionId).listen(
      (eitherPlayers) => eitherPlayers.fold((failure) {
        /* Optionally handle player stream error */
      }, (players) {
        if (state is WordBombGameActive) {
          final currentActiveState = state as WordBombGameActive;
          final currentPlayerName = _getPlayerName(
              currentActiveState.session.currentTurnUserId, players);
          emit(currentActiveState.copyWith(
              players: players, currentPlayerName: currentPlayerName));
        } else if (state is WordBombPaused) {
          final currentPausedState = state as WordBombPaused;
          final currentPlayerName = _getPlayerName(
              currentPausedState.session.currentTurnUserId, players);
          emit(WordBombPaused(
            // Reconstruct paused state with new players
            session: currentPausedState.session,
            gameState: currentPausedState.gameState,
            players: players,
            isAdmin: currentPausedState.isAdmin,
            currentPlayerName: currentPlayerName,
          ));
        }
      }),
    );
  }

  Future<void> _onSubmitWord(
      SubmitWord event, Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive) return;
    final currentActiveState = state as WordBombGameActive;

    final String? currentTurnUser =
        currentActiveState.session.currentTurnUserId;
    if (currentTurnUser == null || _currentUser?.id != currentTurnUser) {
      // Not this player's turn, UI should prevent this, or current turn user is not set
      return;
    }

    _turnTimer?.cancel(); // Stop timer on submission

    final submittedWord = event.word.trim().toLowerCase();
    bool isValidWord = submittedWord.isNotEmpty &&
        !currentActiveState.gameState.usedWords.contains(submittedWord) &&
        submittedWord.startsWith(
            currentActiveState.gameState.currentLetterSyllable.toLowerCase());

    if (isValidWord) {
      final newUsedWords =
          List<String>.from(currentActiveState.gameState.usedWords)
            ..add(submittedWord);

      final nextGameState = currentActiveState.gameState.copyWith(
        usedWords: newUsedWords,
        remainingTimeMs: _wordBombTurnDurationMs,
      );

      final nextPlayerId = _getNextPlayerId(
          currentTurnUser, // Use the validated non-null currentTurnUser
          currentActiveState.players);

      final result = await _updateGameState(UpdateGameStateParams(
        sessionId: currentActiveState.session.id,
        newGameState: WordBombGameStateModelExtension.fromEntity(nextGameState)
            .toJson(), // Corrected call
        currentTurnUserId: nextPlayerId,
      ));
      result.fold((failure) => emit(WordBombError(failure.message)), (_) {
        /* State will update via stream, timer will restart in _onWordBombGameStateUpdated if admin */
      });
    } else {
      // Invalid word or penalty
      // For now, just restart timer for same player (or trigger penalty)
      // This logic can be expanded (e.g. player loses a point, game pauses)
      add(const PauseGameTriggered()); // Example: trigger a pause for penalty
    }
  }

  Future<void> _onNextPlayerTurnRequested(
      NextPlayerTurnRequested event, Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive && state is! WordBombPaused) return;

    GameSession currentSession;
    List<GamePlayer> currentPlayers;
    WordBombGameState currentGameState;

    if (state is WordBombGameActive) {
      final activeState = state as WordBombGameActive;
      currentSession = activeState.session;
      currentPlayers = activeState.players;
      currentGameState = activeState.gameState;
    } else {
      // WordBombPaused
      final pausedState = state as WordBombPaused;
      currentSession = pausedState.session;
      currentPlayers = pausedState.players;
      currentGameState = pausedState.gameState;
    }

    if (!_isAdmin(currentSession)) {
      return;
    } // Only admin can force next turn for now

    _turnTimer?.cancel();

    final String? currentTurnUser = currentSession.currentTurnUserId;
    if (currentTurnUser == null) {
      emit(WordBombError(
          "Impossibile determinare il prossimo giocatore: ID giocatore di turno non impostato."));
      return;
    }

    final nextPlayerId = _getNextPlayerId(currentTurnUser,
        currentPlayers); // Use validated non-null currentTurnUser
    final nextGameState = currentGameState.copyWith(
      remainingTimeMs: _wordBombTurnDurationMs, // Reset timer
      isPaused: false, // Ensure game is not paused
    );

    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: currentSession.id,
      newGameState: WordBombGameStateModelExtension.fromEntity(nextGameState)
          .toJson(), // Corrected call
      currentTurnUserId: nextPlayerId,
    ));

    result.fold((failure) => emit(WordBombError(failure.message)), (_) {
      /* Stream updates state */
    });
  }

  void _onTimerTick(_TimerTick event, Emitter<WordBombState> emit) {
    if (state is! WordBombGameActive) return;
    final currentActiveState = state as WordBombGameActive;

    if (currentActiveState.gameState.isPaused ||
        !_isAdmin(currentActiveState.session)) {
      _turnTimer?.cancel(); // Stop timer if paused or not admin
      return;
    }

    final newTime =
        currentActiveState.gameState.remainingTimeMs - _timerIntervalMs;

    if (newTime <= 0) {
      _turnTimer?.cancel();
      // Time's up! Handle penalty, next player, etc.
      // For now, let's just move to the next player as an example of admin action
      // This should ideally be an event like TimeExpired that admin's client handles
      if (_isAdmin(currentActiveState.session)) {
        add(const NextPlayerTurnRequested()); // Admin moves to next player
      }
      // Non-admins do nothing, wait for admin's game state update
    } else {
      // Admin updates the game state with new time
      // This is frequent, consider if only admin should do this to reduce writes
      // Or, if clients can predict and only sync if desync occurs.
      // For simplicity, admin updates.
      if (_isAdmin(currentActiveState.session)) {
        final updatedGameState =
            currentActiveState.gameState.copyWith(remainingTimeMs: newTime);
        _updateGameState(UpdateGameStateParams(
          // Fire and forget, stream will confirm
          sessionId: currentActiveState.session.id,
          newGameState:
              WordBombGameStateModelExtension.fromEntity(updatedGameState)
                  .toJson(), // Corrected call
        ));
        // Local emit for responsiveness for admin, stream will confirm for others
        // emit(currentActiveState.copyWith(gameState: updatedGameState));
      }
    }
  }

  void _startTurnTimer(Emitter<WordBombState> emit) {
    _turnTimer?.cancel();
    if (state is WordBombGameActive) {
      final currentActiveState = state as WordBombGameActive;
      if (_isAdmin(currentActiveState.session) &&
          !currentActiveState.gameState.isPaused) {
        _turnTimer =
            Timer.periodic(const Duration(milliseconds: _timerIntervalMs), (_) {
          add(const _TimerTick());
        });
      }
    }
  }

  Future<void> _onPauseGameTriggered(
      PauseGameTriggered event, Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive) return;
    final currentActiveState = state as WordBombGameActive;
    if (!_isAdmin(currentActiveState.session)) {
      return;
    } // Only admin can pause for now

    _turnTimer?.cancel();
    final newGameState = currentActiveState.gameState.copyWith(isPaused: true);
    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: currentActiveState.session.id,
      newGameState: WordBombGameStateModelExtension.fromEntity(newGameState)
          .toJson(), // Corrected call
    ));
    // Result handling: stream will update state to WordBombPaused or WordBombGameActive with isPaused=true
    result.fold((failure) => emit(WordBombError(failure.message)), (_) {
      /* Stream updates state */
    });
  }

  Future<void> _onResumeGameTriggered(
      ResumeGameTriggered event, Emitter<WordBombState> emit) async {
    if (state is! WordBombGameActive && state is! WordBombPaused) return;

    GameSession currentSession;
    WordBombGameState currentGameState;

    if (state is WordBombGameActive) {
      currentSession = (state as WordBombGameActive).session;
      currentGameState = (state as WordBombGameActive).gameState;
    } else {
      // WordBombPaused
      currentSession = (state as WordBombPaused).session;
      currentGameState = (state as WordBombPaused).gameState;
    }

    if (!_isAdmin(currentSession)) return;

    final newGameState = currentGameState.copyWith(
        isPaused: false,
        remainingTimeMs:
            _wordBombTurnDurationMs // Optionally reset timer on resume
        );
    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: currentSession.id,
      newGameState: WordBombGameStateModelExtension.fromEntity(newGameState)
          .toJson(), // Corrected call
    ));

    result.fold((failure) => emit(WordBombError(failure.message)), (_) {
      // Stream will update state. If admin, timer will restart in _onWordBombGameStateUpdated.
    });
  }

  void _onWordBombGameStateUpdated(
      _WordBombGameStateUpdated event, Emitter<WordBombState> emit) {
    if (event.session.gameState == null) {
      // This might happen if admin is initializing and non-admin receives session update before game_state is set.
      // Or if game ended and game_state was cleared.
      if (_isAdmin(event.session) &&
          event.session.status == GameStatus.inProgress &&
          (state is WordBombInitial || state is WordBombLoading)) {
        // Admin needs to initialize. This case should be covered by _onInitializeWordBombGame.
        // If players are available, trigger initialization.
        // This indicates a potential race condition or logic gap in initialization.
      } else if (event.session.status != GameStatus.inProgress) {
        _cancelSubscriptions();
        emit(WordBombInitial()); // Game ended or not started properly
      }
      return;
    }

    final wbGameState =
        WordBombGameStateModel.fromJson(event.session.gameState!);
    List<GamePlayer> currentPlayers = [];
    if (state is WordBombGameActive) {
      currentPlayers = (state as WordBombGameActive).players;
    }
    if (state is WordBombPaused) {
      currentPlayers = (state as WordBombPaused).players;
    }
    // If players list isn't populated yet from its own stream, this might be an issue.
    // Assuming players list is reasonably up-to-date from _playersSubscription.

    final currentPlayerName =
        _getPlayerName(event.session.currentTurnUserId, currentPlayers);

    if (wbGameState.isPaused) {
      _turnTimer?.cancel();
      emit(WordBombPaused(
        session: event.session,
        gameState: wbGameState,
        players: currentPlayers, // Use potentially updated players list
        isAdmin: _isAdmin(event.session),
        currentPlayerName: currentPlayerName,
      ));
    } else {
      emit(WordBombGameActive(
        session: event.session,
        gameState: wbGameState,
        players: currentPlayers, // Use potentially updated players list
        isAdmin: _isAdmin(event.session),
        currentPlayerName: currentPlayerName,
      ));
      _startTurnTimer(emit); // Restart timer if admin and game is active
    }

    if (event.session.status == GameStatus.finished ||
        event.session.status == GameStatus.waiting) {
      _cancelSubscriptions();
      // UI should react to status change.
    }
  }

  String? _getPlayerName(String? userId, List<GamePlayer> players) {
    if (userId == null) return null;
    try {
      return players.firstWhere((p) => p.userId == userId).userName;
    } catch (e) {
      return null; // Player not found in current list
    }
  }

  String _getNextPlayerId(String currentUserId, List<GamePlayer> players) {
    if (players.isEmpty) return currentUserId; // Should not happen
    final currentIndex = players.indexWhere((p) => p.userId == currentUserId);
    if (currentIndex == -1 || currentIndex == players.length - 1) {
      return players.first.userId;
    }
    return players[currentIndex + 1].userId;
  }

  void _onErrorOccurred(
      _WordBombErrorOccurred event, Emitter<WordBombState> emit) {
    emit(WordBombError(event.message));
    _cancelSubscriptions();
  }

  void _cancelSubscriptions() {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _playersSubscription?.cancel();
    _playersSubscription = null;
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}

extension WordBombGameStateModelExtension on WordBombGameStateModel {
  static WordBombGameStateModel fromEntity(WordBombGameState entity) {
    return WordBombGameStateModel(
      currentCategory: entity.currentCategory,
      currentLetterSyllable: entity.currentLetterSyllable,
      usedWords: entity.usedWords,
      remainingTimeMs: entity.remainingTimeMs,
      isPaused: entity.isPaused,
      ghostPlayerId: entity.ghostPlayerId,
      totalTurnTimeMs: entity.totalTurnTimeMs, // Added field
    );
  }
}
