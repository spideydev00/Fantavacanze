part of 'word_bomb_bloc.dart';

sealed class WordBombEvent extends Equatable {
  const WordBombEvent();
  @override
  List<Object?> get props => [];
}

class ClearWordBombErrorMessage extends WordBombEvent {
  // Ensure this is a class
  const ClearWordBombErrorMessage();

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
  const PauseGameTriggered();
}

class ResumeGameTriggered extends WordBombEvent {
  const ResumeGameTriggered();
}

class NextPlayerTurnRequested extends WordBombEvent {
  const NextPlayerTurnRequested();
}

class AssignGhostRole extends WordBombEvent {
  final String playerIdToGhost; // ID of the GamePlayer record
  const AssignGhostRole(this.playerIdToGhost); // Added constructor
  @override
  List<Object?> get props => [playerIdToGhost]; // Added to props
}

// Strategic Actions
class RequestStrategicAction extends WordBombEvent {
  final WordBombStrategicActionType actionType;
  const RequestStrategicAction(this.actionType);

  @override
  List<Object?> get props => [actionType];
}

class ConfirmStrategicAction extends WordBombEvent {
  const ConfirmStrategicAction();
}

class CancelStrategicAction extends WordBombEvent {
  const CancelStrategicAction();
}

class ActivateGhostProtocolRequested extends WordBombEvent {
  const ActivateGhostProtocolRequested();
}

class DeactivateGhostProtocolDueToTimeout extends WordBombEvent {
  // Added
  const DeactivateGhostProtocolDueToTimeout();
}

// Round Outcome
class PlayerExploded extends WordBombEvent {
  final String playerId; // Added
  const PlayerExploded(this.playerId); // Added

  @override
  List<Object?> get props => [playerId]; // Added
}

class PlayerAcceptedDefeat extends WordBombEvent {
  const PlayerAcceptedDefeat();
}

class ChallengeInitiated extends WordBombEvent {
  const ChallengeInitiated();
}

// Internal events
class _WordBombGameStateUpdated extends WordBombEvent {
  final GameSession session;
  // final List<GamePlayer> players; // Removed

  const _WordBombGameStateUpdated(this.session /*, this.players*/); // Modified

  @override
  List<Object?> get props => [session /*, players*/]; // Modified
}

class _TimerTick extends WordBombEvent {
  const _TimerTick(); // Added constructor
}

class _WordBombErrorOccurred extends WordBombEvent {
  final String message;
  const _WordBombErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}

class DeactivateTrialRequested extends WordBombEvent {}
