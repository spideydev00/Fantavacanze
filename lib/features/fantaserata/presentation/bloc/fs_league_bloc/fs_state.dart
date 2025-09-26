part of 'fs_bloc.dart';

sealed class FsState {}

final class FantaserataInitial extends FsState {}

final class FantaserataLoading extends FsState {}

final class FantaserataFailure extends FsState {
  final String message;

  FantaserataFailure(this.message);
}

final class FsLeagueLoaded extends FsState {
  final FsLeague league;

  FsLeagueLoaded(this.league);
}

final class FsLeagueCreated extends FsState {
  final FsLeague league;

  FsLeagueCreated(this.league);
}

final class FsLeagueJoined extends FsState {
  final FsLeague league;

  FsLeagueJoined(this.league);
}

final class FsMemoryAdded extends FsState {
  final FsLeague league;

  FsMemoryAdded(this.league);
}

final class FsMemoryDeleted extends FsState {
  final FsLeague league;

  FsMemoryDeleted(this.league);
}

final class FsLeagueExited extends FsState {}

final class FsLeagueDeleted extends FsState {}

final class FsEventAdded extends FsState {
  final FsLeague league;

  FsEventAdded(this.league);
}
