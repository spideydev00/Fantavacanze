part of 'game_bloc.dart';

sealed class LobbyState extends Equatable {
  const LobbyState();
  @override
  List<Object?> get props => [];
}

final class LobbyInitial extends LobbyState {}

final class LobbyLoading extends LobbyState {
  final String? message;
  const LobbyLoading({this.message});
  @override
  List<Object?> get props => [message];
}

final class LobbySessionActive extends LobbyState {
  final GameSession session;
  final List<GamePlayer> players;
  final bool isLoadingNextAction;

  const LobbySessionActive({
    required this.session,
    required this.players,
    this.isLoadingNextAction = false,
  });

  @override
  List<Object?> get props => [session, players, isLoadingNextAction];

  LobbySessionActive copyWith({
    GameSession? session,
    List<GamePlayer>? players,
    bool? isLoadingNextAction,
  }) {
    return LobbySessionActive(
      session: session ?? this.session,
      players: players ?? this.players,
      isLoadingNextAction: isLoadingNextAction ?? this.isLoadingNextAction,
    );
  }
}

final class LobbyError extends LobbyState {
  final String message;
  const LobbyError(this.message);
  @override
  List<Object?> get props => [message];
}
