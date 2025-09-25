part of 'fantaserata_bloc.dart';

sealed class FantaserataEvent {}

final class GetFsLeaguesEvent extends FantaserataEvent {}

final class CreateFsLeagueEvent extends FantaserataEvent {
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

final class JoinFsLeagueEvent extends FantaserataEvent {
  final String inviteCode;
  final String userId;
  final String userName;

  JoinFsLeagueEvent({
    required this.inviteCode,
    required this.userId,
    required this.userName,
  });
}

final class AddFsMemoryEvent extends FantaserataEvent {
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

final class DeleteFsMemoryEvent extends FantaserataEvent {
  final String leagueId;
  final String memoryId;

  DeleteFsMemoryEvent({
    required this.leagueId,
    required this.memoryId,
  });
}

final class ExitFsLeagueEvent extends FantaserataEvent {
  final String leagueId;
  final String userId;

  ExitFsLeagueEvent({
    required this.leagueId,
    required this.userId,
  });
}

final class DeleteFsLeagueEvent extends FantaserataEvent {
  final String leagueId;

  DeleteFsLeagueEvent({required this.leagueId});
}

final class RefreshFsRuleEvent extends FantaserataEvent {
  final String userId;
  final String leagueId;
  final String challengeId;

  RefreshFsRuleEvent({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
  });
}

final class UnlockFsRuleEvent extends FantaserataEvent {
  final String userId;
  final String leagueId;
  final String challengeId;

  UnlockFsRuleEvent({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
  });
}

final class SetRuleAsCompletedEvent extends FantaserataEvent {
  final String userId;
  final String leagueId;
  final String challengeId;
  final String ruleName;
  final double points;
  final String type;

  SetRuleAsCompletedEvent({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
    required this.ruleName,
    required this.points,
    required this.type,
  });
}
