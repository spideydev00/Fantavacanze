part of 'fs_dynamic_rules_bloc.dart';

abstract class FsDynamicRulesEvent extends Equatable {
  const FsDynamicRulesEvent();

  @override
  List<Object?> get props => [];
}

class GetUserDynamicRulesEvent extends FsDynamicRulesEvent {
  final String userId;
  final String leagueId;

  const GetUserDynamicRulesEvent({
    required this.userId,
    required this.leagueId,
  });

  @override
  List<Object> get props => [userId, leagueId];
}

class RefreshDynamicRuleEvent extends FsDynamicRulesEvent {
  final String userId;
  final String leagueId;
  final String challengeId;

  const RefreshDynamicRuleEvent({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
  });

  @override
  List<Object> get props => [userId, leagueId, challengeId];
}

class UnlockDynamicRuleEvent extends FsDynamicRulesEvent {
  final String userId;
  final String leagueId;
  final String challengeId;

  const UnlockDynamicRuleEvent({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
  });

  @override
  List<Object> get props => [userId, leagueId, challengeId];
}

class SetDynamicRuleAsCompletedEvent extends FsDynamicRulesEvent {
  final String userId;
  final String leagueId;
  final String challengeId;
  final String ruleName;
  final double points;
  final String type;

  const SetDynamicRuleAsCompletedEvent({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
    required this.ruleName,
    required this.points,
    required this.type,
  });

  @override
  List<Object> get props =>
      [userId, leagueId, challengeId, ruleName, points, type];
}
