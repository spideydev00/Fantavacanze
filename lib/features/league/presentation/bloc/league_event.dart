import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';

abstract class LeagueEvent extends Equatable {
  const LeagueEvent();

  @override
  List<Object?> get props => [];
}

class CreateLeagueEvent extends LeagueEvent {
  final String name;
  final String? description;
  final bool isTeamBased;
  final List<Rule> rules;

  const CreateLeagueEvent({
    required this.name,
    this.description,
    required this.isTeamBased,
    required this.rules,
  });

  @override
  List<Object?> get props => [name, description, isTeamBased, rules];
}

class GetLeagueEvent extends LeagueEvent {
  final String leagueId;

  const GetLeagueEvent({required this.leagueId});

  @override
  List<Object?> get props => [leagueId];
}

class JoinLeagueEvent extends LeagueEvent {
  final String inviteCode;
  final String? teamName;
  final List<String>? teamMembers;
  final String? specificLeagueId;

  const JoinLeagueEvent({
    required this.inviteCode,
    this.teamName,
    this.teamMembers,
    this.specificLeagueId,
  });

  @override
  List<Object?> get props =>
      [inviteCode, teamName, teamMembers, specificLeagueId];
}

class ExitLeagueEvent extends LeagueEvent {
  final League league;
  final String userId;

  const ExitLeagueEvent({
    required this.league,
    required this.userId,
  });

  @override
  List<Object?> get props => [league, userId];
}

class UpdateTeamNameEvent extends LeagueEvent {
  final League league;
  final String userId;
  final String newName;

  const UpdateTeamNameEvent({
    required this.league,
    required this.userId,
    required this.newName,
  });

  @override
  List<Object?> get props => [league, userId, newName];
}

class AddEventEvent extends LeagueEvent {
  final League league;
  final String name;
  final int points;
  final String creatorId;
  final String targetUser;
  final RuleType type;
  final String? description;

  const AddEventEvent({
    required this.league,
    required this.name,
    required this.points,
    required this.creatorId,
    required this.targetUser,
    required this.type,
    this.description,
  });

  @override
  List<Object?> get props =>
      [league, name, points, creatorId, targetUser, RuleType, description];
}

class AddMemoryEvent extends LeagueEvent {
  final League league;
  final String imageUrl;
  final String text;
  final String userId;
  final String? relatedEventId;

  const AddMemoryEvent({
    required this.league,
    required this.imageUrl,
    required this.text,
    required this.userId,
    this.relatedEventId,
  });

  @override
  List<Object?> get props => [league, imageUrl, text, userId, relatedEventId];
}

class RemoveMemoryEvent extends LeagueEvent {
  final League league;
  final String memoryId;

  const RemoveMemoryEvent({
    required this.league,
    required this.memoryId,
  });

  @override
  List<Object?> get props => [league, memoryId];
}

class GetRulesEvent extends LeagueEvent {
  final String mode;

  const GetRulesEvent({required this.mode});

  @override
  List<Object?> get props => [mode];
}

class UpdateRuleEvent extends LeagueEvent {
  final League league;
  final Rule rule;
  final String? originalRuleName;

  const UpdateRuleEvent({
    required this.league,
    required this.rule,
    this.originalRuleName,
  });

  @override
  List<Object?> get props => [league, rule, originalRuleName];
}

class DeleteRuleEvent extends LeagueEvent {
  final League league;
  final String ruleName;

  const DeleteRuleEvent({
    required this.league,
    required this.ruleName,
  });

  @override
  List<Object?> get props => [league, ruleName];
}

class AddRuleEvent extends LeagueEvent {
  final League league;
  final Rule rule;

  const AddRuleEvent({
    required this.league,
    required this.rule,
  });

  @override
  List<Object?> get props => [league, rule];
}
