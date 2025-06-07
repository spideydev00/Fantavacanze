part of 'truth_or_dare_bloc.dart';

sealed class TruthOrDareEvent extends Equatable {
  const TruthOrDareEvent();
  @override
  List<Object?> get props => [];
}

class InitializeTruthOrDareGame extends TruthOrDareEvent {
  final GameSession initialSession; // Passed from GameHostPage
  const InitializeTruthOrDareGame(this.initialSession);
  @override
  List<Object?> get props => [initialSession];
}

class CardTypeChosen extends TruthOrDareEvent {
  final TruthOrDareCardType cardType; // truth or dare
  const CardTypeChosen(this.cardType);
  @override
  List<Object?> get props => [cardType];
}

class NextPlayerTurn extends TruthOrDareEvent {
  final String nextPlayerId;
  const NextPlayerTurn(this.nextPlayerId);
  @override
  List<Object?> get props => [nextPlayerId];
}

// Internal event for game state updates from stream
class _GameStateUpdated extends TruthOrDareEvent {
  final GameSession session;
  const _GameStateUpdated(this.session);
  @override
  List<Object?> get props => [session];
}

class _TruthOrDareErrorOccurred extends TruthOrDareEvent {
  final String message;
  const _TruthOrDareErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}
