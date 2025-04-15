import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';

abstract class LeagueEvent extends Equatable {
  const LeagueEvent();

  @override
  List<Object?> get props => [];
}

class CreateLeagueEvent extends LeagueEvent {
  final String name;
  final String description;
  final bool isTeamBased;
  final List<Map<String, dynamic>> rules;

  const CreateLeagueEvent({
    required this.name,
    required this.description,
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

class GetUserLeaguesEvent extends LeagueEvent {
  const GetUserLeaguesEvent();
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
  final String leagueId;
  final String userId;

  const ExitLeagueEvent({
    required this.leagueId,
    required this.userId,
  });

  @override
  List<Object?> get props => [leagueId, userId];
}

class UpdateTeamNameEvent extends LeagueEvent {
  final String leagueId;
  final String userId;
  final String newName;

  const UpdateTeamNameEvent({
    required this.leagueId,
    required this.userId,
    required this.newName,
  });

  @override
  List<Object?> get props => [leagueId, userId, newName];
}

class AddEventEvent extends LeagueEvent {
  final String leagueId;
  final String name;
  final int points;
  final String creatorId;
  final String targetUserId;
  final RuleType eventType;
  final String? description;

  AddEventEvent({
    required this.leagueId,
    required this.name,
    required this.points,
    required this.creatorId,
    required this.targetUserId,
    required this.eventType,
    this.description,
  });

  @override
  List<Object?> get props =>
      [leagueId, name, points, creatorId, targetUserId, eventType, description];
}

class AddMemoryEvent extends LeagueEvent {
  final String leagueId;
  final String imageUrl;
  final String text;
  final String userId;
  final String? relatedEventId; // Add relatedEventId

  const AddMemoryEvent({
    required this.leagueId,
    required this.imageUrl,
    required this.text,
    required this.userId,
    this.relatedEventId, // Optional parameter
  });

  @override
  List<Object?> get props => [leagueId, imageUrl, text, userId, relatedEventId];
}

class RemoveMemoryEvent extends LeagueEvent {
  final String leagueId;
  final String memoryId;

  const RemoveMemoryEvent({
    required this.leagueId,
    required this.memoryId,
  });

  @override
  List<Object?> get props => [leagueId, memoryId];
}

class GetRulesEvent extends LeagueEvent {
  final String mode;

  const GetRulesEvent({required this.mode});

  @override
  List<Object?> get props => [mode];
}
