part of 'word_bomb_bloc.dart';

sealed class WordBombEvent extends Equatable {
  const WordBombEvent();
  @override
  List<Object?> get props => [];
}

class InitializeWordBombGame extends WordBombEvent {
  final GameSession initialSession;
  const InitializeWordBombGame(this.initialSession);
  @override
  List<Object?> get props => [initialSession];
}

class SubmitWord extends WordBombEvent {
  final String word;
  const SubmitWord(this.word);
  @override
  List<Object?> get props => [word];
}

class PauseGameTriggered extends WordBombEvent {
  // e.g. player fails, penalty
  const PauseGameTriggered();
}

class ResumeGameTriggered extends WordBombEvent {
  // e.g. after penalty dialog
  const ResumeGameTriggered();
}

class NextPlayerTurnRequested extends WordBombEvent {
  // No specific player ID, game logic determines next player
  const NextPlayerTurnRequested();
}

class AssignGhostRole extends WordBombEvent {
  final String playerIdToGhost; // ID of the GamePlayer record
  const AssignGhostRole(this.playerIdToGhost);
  @override
  List<Object?> get props => [playerIdToGhost];
}

// Internal events
class _WordBombGameStateUpdated extends WordBombEvent {
  final GameSession session;
  const _WordBombGameStateUpdated(this.session);
  @override
  List<Object?> get props => [session];
}

class _TimerTick extends WordBombEvent {
  const _TimerTick();
}

class _WordBombErrorOccurred extends WordBombEvent {
  final String message;
  const _WordBombErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}
