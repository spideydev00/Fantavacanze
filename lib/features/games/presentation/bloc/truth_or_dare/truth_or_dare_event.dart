part of 'truth_or_dare_bloc.dart';

sealed class TruthOrDareEvent extends Equatable {
  const TruthOrDareEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTruthOrDareGame extends TruthOrDareEvent {
  final GameSession initialSession;

  const InitializeTruthOrDareGame(this.initialSession);

  @override
  List<Object?> get props => [initialSession];
}

class CardTypeChosen extends TruthOrDareEvent {
  final TruthOrDareCardType cardType;

  const CardTypeChosen(this.cardType);

  @override
  List<Object?> get props => [cardType];
}

class PlayerTaskOutcomeSubmitted extends TruthOrDareEvent {
  final bool isSuccess;

  const PlayerTaskOutcomeSubmitted({required this.isSuccess});

  @override
  List<Object?> get props => [isSuccess];
}

class ChangeQuestionRequested extends TruthOrDareEvent {
  const ChangeQuestionRequested();
}

// Internal events for stream updates
class _TruthOrDareSessionUpdated extends TruthOrDareEvent {
  final GameSession session;
  const _TruthOrDareSessionUpdated(this.session);
  @override
  List<Object?> get props => [session];
}

class _TruthOrDarePlayersUpdated extends TruthOrDareEvent {
  final List<GamePlayer> players;
  const _TruthOrDarePlayersUpdated(this.players);
  @override
  List<Object?> get props => [players];
}

class _TruthOrDareStreamErrorOccurred extends TruthOrDareEvent {
  final String message;
  const _TruthOrDareStreamErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}
