part of 'fantaserata_bloc.dart';

sealed class FantaserataState {}

final class FantaserataInitial extends FantaserataState {}

final class FantaserataLoading extends FantaserataState {}

final class FantaserataFailure extends FantaserataState {
  final String message;

  FantaserataFailure(this.message);
}

final class FsLeagueLoaded extends FantaserataState {
  final FsLeague league;

  FsLeagueLoaded(this.league);
}

final class FsLeagueNotExists extends FantaserataState {}

final class FsLeagueCreated extends FantaserataState {
  final FsLeague league;

  FsLeagueCreated(this.league);
}

final class FsLeagueJoined extends FantaserataState {
  final FsLeague league;

  FsLeagueJoined(this.league);
}

final class FsMemoryAdded extends FantaserataState {
  final FsMemory memory;

  FsMemoryAdded(this.memory);
}

final class FsMemoryDeleted extends FantaserataState {}

final class FsLeagueExited extends FantaserataState {}

final class FsLeagueDeleted extends FantaserataState {}

final class FsRuleRefreshed extends FantaserataState {}

final class FsRuleUnlocked extends FantaserataState {}

final class FsRuleCompleted extends FantaserataState {}
