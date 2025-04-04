import 'package:equatable/equatable.dart';

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

  const ExitLeagueEvent({required this.leagueId});

  @override
  List<Object?> get props => [leagueId];
}

class UpdateTeamNameEvent extends LeagueEvent {
  final String leagueId;
  final String newName;

  const UpdateTeamNameEvent({
    required this.leagueId,
    required this.newName,
  });

  @override
  List<Object?> get props => [leagueId, newName];
}

class AddEventEvent extends LeagueEvent {
  final String leagueId;
  final String name;
  final int points;
  final String eventType;
  final String? description;

  const AddEventEvent({
    required this.leagueId,
    required this.name,
    required this.points,
    required this.eventType,
    this.description,
  });

  @override
  List<Object?> get props => [leagueId, name, points, eventType, description];
}

class AddMemoryEvent extends LeagueEvent {
  final String leagueId;
  final String imageUrl;
  final String text;
  final String? relatedEventId;

  const AddMemoryEvent({
    required this.leagueId,
    required this.imageUrl,
    required this.text,
    this.relatedEventId,
  });

  @override
  List<Object?> get props => [leagueId, imageUrl, text, relatedEventId];
}
