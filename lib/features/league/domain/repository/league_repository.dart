import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fpdart/fpdart.dart';

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
  Future<Either<Failure, League>> joinLeague({
    required String inviteCode,
    required String userId,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  });

  Future<Either<Failure, League>> exitLeague({
    required League league,
    required String userId,
  });

  Future<Either<Failure, League>> updateTeamName({
    required League league,
    required String userId,
    required String newName,
  });

  // Event operations
  Future<Either<Failure, League>> addEvent({
    required League league,
    required String name,
    required int points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? description,
  });

  Future<Either<Failure, League>> removeEvent({
    required League league,
    required String eventId,
  });

  // Memory operations
  Future<Either<Failure, League>> addMemory({
    required League league,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
  });

  Future<Either<Failure, League>> removeMemory({
    required League league,
    required String memoryId,
  });

  // Rules operations
  Future<Either<Failure, List<Rule>>> getRules(String mode);

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
}
