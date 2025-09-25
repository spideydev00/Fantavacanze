part of 'app_fs_league_cubit.dart';

sealed class AppFsLeagueState {}

final class AppFsLeagueInitial extends AppFsLeagueState {}

final class AppFsLeagueExists extends AppFsLeagueState {
  final FsLeague league;

  AppFsLeagueExists(this.league);
}

final class AppFsLeagueNotExists extends AppFsLeagueState {}
