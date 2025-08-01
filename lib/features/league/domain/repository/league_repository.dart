import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model/note_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/note.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:io';

abstract class LeagueRepository {
  Future<Either<Failure, League>> createLeague({
    required String name,
    String? description,
    required bool isTeamBased,
    required List<Rule> rules,
  });

  Future<Either<Failure, League>> getLeague(String leagueId);

  Future<Either<Failure, List<League>>> getUserLeagues();

  Future<Either<Failure, League>> updateLeagueNameOrDescription({
    required String leagueId,
    String? name,
    String? description,
  });

  Future<Either<Failure, void>> deleteLeague(String leagueId);

  // Participant operations
  Future<Either<Failure, List<League>>> searchLeague(
      {required String inviteCode});

  Future<Either<Failure, League>> joinLeague({
    required String inviteCode,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  });

  Future<Either<Failure, void>> exitLeague({
    required League league,
    required String userId,
  });

  Future<Either<Failure, League>> updateTeamName({
    required League league,
    required String userId,
    required String newName,
  });

  Future<Either<Failure, League>> removeTeamParticipants({
    required League league,
    required String teamName,
    required List<String> userIdsToRemove,
    required String requestingUserId,
  });

  // Event operations
  Future<Either<Failure, League>> addEvent({
    required League league,
    required String name,
    required double points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    required bool isTeamMember,
    String? description,
  });

  Future<Either<Failure, League>> removeEvent({
    required League league,
    required String eventId,
  });

  Future<Either<Failure, League>> addMemory({
    required League league,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
    String? eventName,
  });

  Future<Either<Failure, League>> removeMemory({
    required League league,
    required String memoryId,
  });

  Future<Either<Failure, League>> addRule({
    required League league,
    required Rule rule,
  });

  Future<Either<Failure, League>> updateRule({
    required League league,
    required Rule rule,
    String? originalRuleName,
  });

  Future<Either<Failure, League>> deleteRule({
    required League league,
    required String ruleName,
  });

  // Cache operations
  Future<Either<Failure, void>> clearLocalCache();

  // Note operations
  Future<Either<Failure, List<NoteModel>>> getNotes(String leagueId);
  Future<Either<Failure, void>> saveNote(String leagueId, Note note);
  Future<Either<Failure, void>> deleteNote(String leagueId, String noteId);

  // Media operations
  Future<Either<Failure, String>> uploadMedia({
    required String leagueId,
    required File mediaFile,
  });

  Future<Either<Failure, String>> uploadTeamLogo({
    required String leagueId,
    required String teamName,
    required File imageFile,
  });

  Future<Either<Failure, League>> updateTeamLogo({
    required League league,
    required String teamName,
    required String logoUrl,
  });

  // New admin operations
  Future<Either<Failure, League>> addAdministrators({
    required League league,
    required List<String> userIds,
  });

  Future<Either<Failure, League>> removeParticipants({
    required League league,
    required List<String> participantIds,
    String? newCaptainId,
  });

  Future<Either<Failure, League>> updateLeagueInfo({
    required League league,
    String? name,
    String? description,
  });
}
