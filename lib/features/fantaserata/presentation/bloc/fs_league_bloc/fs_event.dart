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

final class AddFsMemoryEvent extends FsEvent {
  final String leagueId;
  final String imageUrl;
  final String description;
  final String userId;
  final String participantName;
  final String? relatedEventId;
  final String? eventName;

  AddFsMemoryEvent({
    required this.leagueId,
    required this.imageUrl,
    required this.description,
    required this.userId,
    required this.participantName,
    this.relatedEventId,
    this.eventName,
  });
}

final class DeleteFsMemoryEvent extends FsEvent {
  final String leagueId;
  final String memoryId;

  DeleteFsMemoryEvent({
    required this.leagueId,
    required this.memoryId,
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

  DeleteFsLeagueEvent({required this.leagueId});
}

final class AddFsEventEvent extends FsEvent {
  final String leagueId;
  final String name;
  final double points;
  final String targetParticipantId;
  final String type;

  AddFsEventEvent({
    required this.leagueId,
    required this.name,
    required this.points,
    required this.targetParticipantId,
    required this.type,
  });
}
