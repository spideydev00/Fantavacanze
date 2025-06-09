part of 'word_bomb_bloc.dart';

sealed class WordBombState extends Equatable {
  const WordBombState();

  @override
  List<Object?> get props => [];
}

final class WordBombInitial extends WordBombState {}

final class WordBombLoading extends WordBombState {}

final class WordBombError extends WordBombState {
  final String message;
  const WordBombError(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class WordBombSessionState extends WordBombState {
  final GameSession session;
  final List<GamePlayer> players;
  final WordBombGameState gameState;
  final bool isAdmin;
  final String? currentPlayerName;

  const WordBombSessionState({
    required this.session,
    required this.players,
    required this.gameState,
    required this.isAdmin,
    this.currentPlayerName,
  });

  @override
  List<Object?> get props =>
      [session, players, gameState, isAdmin, currentPlayerName];
}

final class WordBombGameActive extends WordBombSessionState {
  final String? currentUserId; // ID of the user using the app
  final String? errorMessage; // For non-fatal errors shown in UI

  const WordBombGameActive({
    required super.session,
    required super.players,
    required super.gameState,
    required super.isAdmin,
    super.currentPlayerName,
    this.currentUserId,
    this.errorMessage,
  });

  WordBombGameActive copyWith({
    GameSession? session,
    List<GamePlayer>? players,
    WordBombGameState? gameState,
    bool? isAdmin,
    String? currentPlayerName,
    String? currentUserId,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return WordBombGameActive(
      session: session ?? this.session,
      players: players ?? this.players,
      gameState: gameState ?? this.gameState,
      isAdmin: isAdmin ?? this.isAdmin,
      currentPlayerName: currentPlayerName ?? this.currentPlayerName,
      currentUserId: currentUserId ?? this.currentUserId,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => super.props..addAll([currentUserId, errorMessage]);
}

final class WordBombPaused extends WordBombSessionState {
  const WordBombPaused({
    required super.session,
    required super.players,
    required super.gameState,
    required super.isAdmin,
    super.currentPlayerName,
  });

  WordBombPaused copyWith({
    GameSession? session,
    List<GamePlayer>? players,
    WordBombGameState? gameState,
    bool? isAdmin,
    String? currentPlayerName,
  }) {
    return WordBombPaused(
      session: session ?? this.session,
      players: players ?? this.players,
      gameState: gameState ?? this.gameState,
      isAdmin: isAdmin ?? this.isAdmin,
      currentPlayerName: currentPlayerName ?? this.currentPlayerName,
    );
  }
}

final class WordBombAwaitingConfirmation extends WordBombSessionState {
  final WordBombStrategicActionType actionBeingConfirmed;

  const WordBombAwaitingConfirmation({
    required super.session,
    required super.players,
    required super.gameState, // This gameState will have isPaused=true
    required super.isAdmin,
    super.currentPlayerName,
    required this.actionBeingConfirmed,
  });

  @override
  List<Object?> get props => super.props..add(actionBeingConfirmed);

  WordBombAwaitingConfirmation copyWith({
    GameSession? session,
    List<GamePlayer>? players,
    WordBombGameState? gameState,
    bool? isAdmin,
    String? currentPlayerName,
    WordBombStrategicActionType? actionBeingConfirmed,
  }) {
    return WordBombAwaitingConfirmation(
      session: session ?? this.session,
      players: players ?? this.players,
      gameState: gameState ?? this.gameState,
      isAdmin: isAdmin ?? this.isAdmin,
      currentPlayerName: currentPlayerName ?? this.currentPlayerName,
      actionBeingConfirmed: actionBeingConfirmed ?? this.actionBeingConfirmed,
    );
  }
}

final class WordBombPlayerExploded extends WordBombSessionState {
  final String explodedPlayerId;

  const WordBombPlayerExploded({
    required super.session,
    required super.players,
    required super.gameState,
    required super.isAdmin,
    super.currentPlayerName,
    required this.explodedPlayerId,
  });

  WordBombPlayerExploded copyWith({
    GameSession? session,
    List<GamePlayer>? players,
    WordBombGameState? gameState,
    bool? isAdmin,
    String? currentPlayerName,
    String? explodedPlayerId,
  }) {
    return WordBombPlayerExploded(
      session: session ?? this.session,
      players: players ?? this.players,
      gameState: gameState ?? this.gameState,
      isAdmin: isAdmin ?? this.isAdmin,
      currentPlayerName: currentPlayerName ?? this.currentPlayerName,
      explodedPlayerId: explodedPlayerId ?? this.explodedPlayerId,
    );
  }

  @override
  List<Object?> get props => super.props..add(explodedPlayerId);
}
