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
  final FsRule rule;

  const SetRuleAsCompletedEvent({
    required this.rule,
  });

  @override
  List<Object> get props => [rule];
}

class SetRuleAsUncompletedEvent extends FsRulesEvent {
  final FsRule rule;
  final String? completionId;

  const SetRuleAsUncompletedEvent({
    required this.rule,
    this.completionId,
  });

  @override
  List<Object?> get props => [rule, completionId];
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
