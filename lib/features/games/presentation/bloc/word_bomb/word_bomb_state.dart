part of 'word_bomb_bloc.dart';

sealed class WordBombState extends Equatable {
  const WordBombState();
  @override
  List<Object?> get props => [];
}

final class WordBombInitial extends WordBombState {}

final class WordBombLoading extends WordBombState {}

final class WordBombGameActive extends WordBombState {
  final GameSession session;
  final WordBombGameState gameState;
  final List<GamePlayer> players;
  final bool isAdmin;
  final String? currentPlayerName;

  const WordBombGameActive({
    required this.session,
    required this.gameState,
    required this.players,
    required this.isAdmin,
    this.currentPlayerName,
  });

  @override
  List<Object?> get props =>
      [session, gameState, players, isAdmin, currentPlayerName];

  WordBombGameActive copyWith({
    GameSession? session,
    WordBombGameState? gameState,
    List<GamePlayer>? players,
    bool? isAdmin,
    String? currentPlayerName,
  }) {
    return WordBombGameActive(
      session: session ?? this.session,
      gameState: gameState ?? this.gameState,
      players: players ?? this.players,
      isAdmin: isAdmin ?? this.isAdmin,
      currentPlayerName: currentPlayerName ?? this.currentPlayerName,
    );
  }
}

// This state might not be strictly necessary if 'isPaused' is in WordBombGameState
// However, it can be useful for distinct UI changes during pause.
final class WordBombPaused extends WordBombState {
  final GameSession session;
  final WordBombGameState gameState;
  final List<GamePlayer> players;
  final bool isAdmin;
  final String? currentPlayerName;

  const WordBombPaused({
    required this.session,
    required this.gameState,
    required this.players,
    required this.isAdmin,
    this.currentPlayerName,
  });

  @override
  List<Object?> get props =>
      [session, gameState, players, isAdmin, currentPlayerName];
}

final class WordBombError extends WordBombState {
  final String message;
  const WordBombError(this.message);
  @override
  List<Object?> get props => [message];
}
