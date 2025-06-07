part of 'lobby_bloc.dart';

sealed class LobbyEvent extends Equatable {
  const LobbyEvent();
  @override
  List<Object?> get props => [];
}

class CreateSessionRequested extends LobbyEvent {
  final GameType gameType;
  const CreateSessionRequested(this.gameType);
  @override
  List<Object?> get props => [gameType];
}

class JoinSessionRequested extends LobbyEvent {
  final String inviteCode;
  const JoinSessionRequested(this.inviteCode);
  @override
  List<Object?> get props => [inviteCode];
}

class LeaveSessionRequested extends LobbyEvent {
  final String sessionId;
  const LeaveSessionRequested(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

class StartGameRequested extends LobbyEvent {
  final String sessionId;
  const StartGameRequested(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

// Internal events for stream updates
class _SessionUpdated extends LobbyEvent {
  final GameSession session;
  const _SessionUpdated(this.session);
  @override
  List<Object?> get props => [session];
}

class _PlayersUpdated extends LobbyEvent {
  final List<GamePlayer> players;
  const _PlayersUpdated(this.players);
  @override
  List<Object?> get props => [players];
}

class _StreamErrorOccurred extends LobbyEvent {
  final String message;
  const _StreamErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}
