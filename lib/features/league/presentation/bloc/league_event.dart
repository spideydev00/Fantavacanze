import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'dart:io';

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
  final double points;
  final String creatorId;
  final String targetUser;
  final RuleType type;
  final String? description;
  final bool isTeamMember;

  const AddEventEvent({
    required this.league,
    required this.name,
    required this.points,
    required this.creatorId,
    required this.targetUser,
    required this.type,
    this.description,
    this.isTeamMember = false,
  });

  @override
  List<Object?> get props => [
        league,
        name,
        points,
        creatorId,
        targetUser,
        type,
        description,
        isTeamMember,
      ];
}

class AddMemoryEvent extends LeagueEvent {
  final League league;
  final String imageUrl;
  final String text;
  final String userId;
  final String? relatedEventId;
  final String? eventName;

  const AddMemoryEvent({
    required this.league,
    required this.imageUrl,
    required this.text,
    required this.userId,
    this.relatedEventId,
    this.eventName,
  });

  @override
  List<Object?> get props =>
      [league, imageUrl, text, userId, relatedEventId, eventName];
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

class RemoveTeamParticipantsEvent extends LeagueEvent {
  final League league;
  final String teamName;
  final List<String> userIdsToRemove;

  const RemoveTeamParticipantsEvent({
    required this.league,
    required this.teamName,
    required this.userIdsToRemove,
  });

  @override
  List<Object?> get props => [league, teamName, userIdsToRemove];
}

class SearchLeagueEvent extends LeagueEvent {
  final String inviteCode;

  const SearchLeagueEvent({required this.inviteCode});

  @override
  List<Object?> get props => [inviteCode];
}

class GetNotesEvent extends LeagueEvent {
  final String leagueId;

  const GetNotesEvent({required this.leagueId});

  @override
  List<Object?> get props => [leagueId];
}

class SaveNoteEvent extends LeagueEvent {
  final String leagueId;
  final NoteModel note;

  const SaveNoteEvent({
    required this.leagueId,
    required this.note,
  });

  @override
  List<Object?> get props => [leagueId, note];
}

class DeleteNoteEvent extends LeagueEvent {
  final String leagueId;
  final String noteId;

  const DeleteNoteEvent({
    required this.leagueId,
    required this.noteId,
  });

  @override
  List<Object?> get props => [leagueId, noteId];
}

class UploadImageEvent extends LeagueEvent {
  final String leagueId;
  final File imageFile;

  const UploadImageEvent({
    required this.leagueId,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [leagueId, imageFile];
}

class UploadTeamLogoEvent extends LeagueEvent {
  final String leagueId;
  final String teamName;
  final File imageFile;

  const UploadTeamLogoEvent({
    required this.leagueId,
    required this.teamName,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [leagueId, teamName, imageFile];
}

class UpdateTeamLogoEvent extends LeagueEvent {
  final League league;
  final String teamName;
  final String logoUrl;

  const UpdateTeamLogoEvent({
    required this.league,
    required this.teamName,
    required this.logoUrl,
  });

  @override
  List<Object?> get props => [league, teamName, logoUrl];
}

class AddAdministratorsEvent extends LeagueEvent {
  final League league;
  final List<String> userIds;

  const AddAdministratorsEvent({
    required this.league,
    required this.userIds,
  });

  @override
  List<Object?> get props => [league, userIds];
}

class RemoveParticipantsEvent extends LeagueEvent {
  final League league;
  final List<String> participantIds;
  final String? newCaptainId;

  const RemoveParticipantsEvent({
    required this.league,
    required this.participantIds,
    this.newCaptainId,
  });

  @override
  List<Object?> get props => [league, participantIds, newCaptainId];
}

class UpdateLeagueInfoEvent extends LeagueEvent {
  final League league;
  final String? name;
  final String? description;

  const UpdateLeagueInfoEvent({
    required this.league,
    this.name,
    this.description,
  });

  @override
  List<Object?> get props => [league, name, description];
}

class DeleteLeagueEvent extends LeagueEvent {
  final String leagueId;

  const DeleteLeagueEvent({required this.leagueId});

  @override
  List<Object?> get props => [leagueId];
}

// Daily challenges events
class GetDailyChallengesEvent extends LeagueEvent {
  final String userId;

  const GetDailyChallengesEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

class MarkChallengeAsCompletedEvent extends LeagueEvent {
  final DailyChallenge challenge;
  final String userId;
  final League league;

  const MarkChallengeAsCompletedEvent({
    required this.challenge,
    required this.userId,
    required this.league,
  });

  @override
  List<Object?> get props => [challenge, userId, league];
}

class RefreshDailyChallengeEvent extends LeagueEvent {
  final String challengeId;
  final String userId;
  final int primaryIndex;

  const RefreshDailyChallengeEvent({
    required this.challengeId,
    required this.userId,
    required this.primaryIndex,
  });

  @override
  List<Object?> get props => [challengeId, userId, primaryIndex];
}
