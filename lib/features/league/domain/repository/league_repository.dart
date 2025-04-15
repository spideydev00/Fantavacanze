import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fpdart/fpdart.dart';

abstract class LeagueRepository {
  // League operations
  Future<Either<Failure, League>> createLeague({
    required String name,
    String? description,
    required bool isTeamBased,
    required List<String> admins,
    required List<Map<String, dynamic>> rules,
  });

  Future<Either<Failure, League>> getLeague(String leagueId);

  Future<Either<Failure, List<League>>> getUserLeagues();

  Future<Either<Failure, League>> updateLeague({
    required String leagueId,
    String? name,
    String? description,
  });

  Future<Either<Failure, void>> deleteLeague(String leagueId);

  // Participant operations
  Future<Either<Failure, League>> joinLeague({
    required String inviteCode,
    required String userId,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  });

  Future<Either<Failure, League>> exitLeague({
    required String leagueId,
    required String userId,
  });

  Future<Either<Failure, League>> updateTeamName({
    required String leagueId,
    required String userId,
    required String newName,
  });

  // Event operations
  Future<Either<Failure, League>> addEvent({
    required String leagueId,
    required String name,
    required int points,
    required String creatorId,
    required String targetUserId,
    required RuleType eventType,
    String? description,
  });

  Future<Either<Failure, League>> removeEvent({
    required String leagueId,
    required String eventId,
  });

  // Memory operations
  Future<Either<Failure, League>> addMemory({
    required String leagueId,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
  });

  Future<Either<Failure, League>> removeMemory({
    required String leagueId,
    required String memoryId,
  });

  // Rules operations
  Future<Either<Failure, List<Rule>>> getRules(String mode);
}
