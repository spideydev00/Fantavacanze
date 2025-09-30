part of 'fs_bloc.dart';

sealed class FsEvent {}

final class GetFsLeagueEvent extends FsEvent {}

final class CreateFsLeagueEvent extends FsEvent {
  final String name;
  final String? description;
  final String creatorId;
  final String creatorName;

  CreateFsLeagueEvent({
    required this.name,
    this.description,
    required this.creatorId,
    required this.creatorName,
  });
}

final class JoinFsLeagueEvent extends FsEvent {
  final String inviteCode;
  final String userId;
  final String userName;

  JoinFsLeagueEvent({
    required this.inviteCode,
    required this.userId,
    required this.userName,
  });
}

final class ExitFsLeagueEvent extends FsEvent {
  final String leagueId;
  final String userId;

  ExitFsLeagueEvent({
    required this.leagueId,
    required this.userId,
  });
}

final class DeleteFsLeagueEvent extends FsEvent {
  final String leagueId;

  DeleteFsLeagueEvent({
    required this.leagueId,
  });
}

final class UploadWinnerPhotoEvent extends FsEvent {
  final String leagueId;
  final Uint8List imageBytes;

  UploadWinnerPhotoEvent({
    required this.leagueId,
    required this.imageBytes,
  });
}

final class DeleteWinnerPhotoEvent extends FsEvent {
  final String leagueId;

  DeleteWinnerPhotoEvent({
    required this.leagueId,
  });
}
