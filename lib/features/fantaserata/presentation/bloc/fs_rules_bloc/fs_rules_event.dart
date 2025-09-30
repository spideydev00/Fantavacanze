part of 'fs_rules_bloc.dart';

abstract class FsRulesEvent extends Equatable {
  const FsRulesEvent();

  @override
  List<Object?> get props => [];
}

class RefreshRuleEvent extends FsRulesEvent {
  final String leagueId;
  final String challengeId;

  const RefreshRuleEvent({
    required this.leagueId,
    required this.challengeId,
  });

  @override
  List<Object> get props => [leagueId, challengeId];
}

class UnlockRuleEvent extends FsRulesEvent {
  final String leagueId;
  final String challengeId;

  const UnlockRuleEvent({
    required this.leagueId,
    required this.challengeId,
  });

  @override
  List<Object> get props => [leagueId, challengeId];
}

class LockRuleEvent extends FsRulesEvent {
  final String leagueId;
  final String challengeId;

  const LockRuleEvent({
    required this.leagueId,
    required this.challengeId,
  });

  @override
  List<Object> get props => [leagueId, challengeId];
}

class SetRuleAsCompletedEvent extends FsRulesEvent {
  final String leagueId;
  final String challengeId;
  final String ruleName;
  final double points;
  final String type;

  const SetRuleAsCompletedEvent({
    required this.leagueId,
    required this.challengeId,
    required this.ruleName,
    required this.points,
    required this.type,
  });

  @override
  List<Object> get props => [leagueId, challengeId, ruleName, points, type];
}

class SetRuleAsUncompletedEvent extends FsRulesEvent {
  final String leagueId;
  final String userId;
  final String challengeId;

  const SetRuleAsUncompletedEvent({
    required this.leagueId,
    required this.userId,
    required this.challengeId,
  });

  @override
  List<Object> get props => [leagueId, userId, challengeId];
}

class InsertRulesForLeagueFromExistingEvent extends FsRulesEvent {
  final String leagueId;
  final String name;
  final num points;
  final String typeText;

  const InsertRulesForLeagueFromExistingEvent({
    required this.leagueId,
    required this.name,
    required this.points,
    required this.typeText,
  });

  @override
  List<Object> get props => [leagueId, name, points, typeText];
}

class GetLeagueRulesEvent extends FsRulesEvent {
  final String leagueId;

  const GetLeagueRulesEvent({
    required this.leagueId,
  });

  @override
  List<Object> get props => [leagueId];
}

class UpdateRulesLocallyEvent extends FsRulesEvent {
  final List<FsRule> rules;
  final bool isPremium;

  const UpdateRulesLocallyEvent({
    required this.rules,
    required this.isPremium,
  });

  @override
  List<Object> get props => [rules, isPremium];
}
