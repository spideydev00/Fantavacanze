part of 'never_have_i_ever_bloc.dart';

sealed class NeverHaveIEverEvent extends Equatable {
  const NeverHaveIEverEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNeverHaveIEverGame extends NeverHaveIEverEvent {
  final GameSession initialSession;

  const InitializeNeverHaveIEverGame(this.initialSession);

  @override
  List<Object?> get props => [initialSession];
}

class NextQuestionRequested extends NeverHaveIEverEvent {
  const NextQuestionRequested();
}

// Internal events for stream updates
class _NeverHaveIEverSessionUpdated extends NeverHaveIEverEvent {
  final GameSession session;
  const _NeverHaveIEverSessionUpdated(this.session);
  @override
  List<Object?> get props => [session];
}

class _NeverHaveIEverPlayersUpdated extends NeverHaveIEverEvent {
  final List<GamePlayer> players;
  const _NeverHaveIEverPlayersUpdated(this.players);
  @override
  List<Object?> get props => [players];
}

class _NeverHaveIEverStreamErrorOccurred extends NeverHaveIEverEvent {
  final String message;
  const _NeverHaveIEverStreamErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}
