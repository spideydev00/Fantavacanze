import 'package:equatable/equatable.dart';

class WordBombGameState extends Equatable {
  final String currentCategory;
  final String currentLetterSyllable;
  final List<String> usedWords;
  final int remainingTimeMs;
  final bool isPaused; // For active pause (e.g., drinking penalty)
  final String? ghostPlayerId; // ID of the player who is the ghost
  final int totalTurnTimeMs;

  const WordBombGameState({
    required this.currentCategory,
    required this.currentLetterSyllable,
    required this.usedWords,
    required this.remainingTimeMs,
    this.isPaused = false,
    this.ghostPlayerId,
    required this.totalTurnTimeMs,
  });

  WordBombGameState copyWith({
    String? currentCategory,
    String? currentLetterSyllable,
    List<String>? usedWords,
    int? remainingTimeMs,
    bool? isPaused,
    String? ghostPlayerId,
    bool clearGhostPlayerId =
        false, // Helper to explicitly nullify ghostPlayerId
    int? totalTurnTimeMs,
  }) {
    return WordBombGameState(
      currentCategory: currentCategory ?? this.currentCategory,
      currentLetterSyllable:
          currentLetterSyllable ?? this.currentLetterSyllable,
      usedWords: usedWords ?? this.usedWords,
      remainingTimeMs: remainingTimeMs ?? this.remainingTimeMs,
      isPaused: isPaused ?? this.isPaused,
      ghostPlayerId:
          clearGhostPlayerId ? null : ghostPlayerId ?? this.ghostPlayerId,
      totalTurnTimeMs: totalTurnTimeMs ?? this.totalTurnTimeMs,
    );
  }

  @override
  List<Object?> get props => [
        currentCategory,
        currentLetterSyllable,
        usedWords,
        remainingTimeMs,
        isPaused,
        ghostPlayerId,
        totalTurnTimeMs,
      ];
}
