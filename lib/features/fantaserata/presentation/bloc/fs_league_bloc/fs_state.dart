part of 'fs_bloc.dart';

sealed class FsState {}

final class FsInitial extends FsState {}

final class FsLoading extends FsState {}

final class FsFailure extends FsState {
  final String message;

  FsFailure(this.message);
}

final class FsLeagueLoaded extends FsState {
  final FsLeague league;

  FsLeagueLoaded(this.league);
}

final class FsLeagueCreated extends FsState {
  final FsLeague league;

  FsLeagueCreated(this.league);
}

final class FsNightSpecificLeagueCreated extends FsState {
  final FsLeague league;

  FsNightSpecificLeagueCreated(this.league);
}

final class FsLeagueJoined extends FsState {
  final FsLeague league;

  FsLeagueJoined(this.league);
}

final class FsNightSpecificLeagueJoined extends FsState {
  final FsLeague league;

  FsNightSpecificLeagueJoined(this.league);
}

final class FsLeagueExited extends FsState {}

final class FsLeagueDeleted extends FsState {}

final class WinnerPhotoUploaded extends FsState {
  final String imageUrl;

  WinnerPhotoUploaded(this.imageUrl);
}

final class WinnerPhotoDeleted extends FsState {}
