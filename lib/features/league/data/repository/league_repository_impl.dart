import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/league/data/datasources/league_local_data_source.dart';
import 'package:fantavacanze_official/features/league/data/datasources/league_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';

class LeagueRepositoryImpl implements LeagueRepository {
  final LeagueRemoteDataSource remoteDataSource;
  final LeagueLocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  LeagueRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, League>> createLeague({
    required String name,
    String? description,
    required bool isTeamBased,
    required List<String> admins,
    required List<Map<String, dynamic>> rules,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final league = await remoteDataSource.createLeague(
        name: name,
        description: description ?? "",
        isTeamBased: isTeamBased,
        admins: admins,
        rules: rules,
      );

      // Cache the newly created league
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> getLeague(String leagueId) async {
    try {
      if (!await connectionChecker.isConnected) {
        // Try to get league from cache when offline
        final cachedLeague = await localDataSource.getCachedLeague(leagueId);
        if (cachedLeague != null) {
          return Right(cachedLeague);
        }
        return Left(
          Failure("Nessuna connessione e nessun dato nella cache."),
        );
      }

      // Get from remote and cache
      final league = await remoteDataSource.getLeague(leagueId);
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      // If server error, try to get from cache
      try {
        final cachedLeague = await localDataSource.getCachedLeague(leagueId);
        if (cachedLeague != null) {
          return Right(cachedLeague);
        }
      } catch (_) {}
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<League>>> getUserLeagues() async {
    try {
      if (!await connectionChecker.isConnected) {
        // Return cached leagues when offline
        final cachedLeagues = await localDataSource.getCachedLeagues();
        return Right(cachedLeagues);
      }

      // Get from remote and cache
      final leagues = await remoteDataSource.getUserLeagues();
      await localDataSource.cacheLeagues(leagues);

      return Right(leagues);
    } on ServerException catch (e) {
      // If server error, try to get from cache
      try {
        final cachedLeagues = await localDataSource.getCachedLeagues();
        return Right(cachedLeagues);
      } catch (_) {}
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> updateLeague({
    required String leagueId,
    String? name,
    String? description,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
            "Nessuna connessione ad internet, riprova appena sarai connesso.",
          ),
        );
      }

      final league = await remoteDataSource.updateLeague(
        leagueId: leagueId,
        name: name,
        description: description,
      );

      // Update cache
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLeague(String leagueId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      await remoteDataSource.deleteLeague(leagueId);

      // Remove from cache
      // We might need to add a method to remove a specific league from cache

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> joinLeague({
    required String inviteCode,
    required String userId,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final league = await remoteDataSource.joinLeague(
        inviteCode: inviteCode,
        userId: userId,
        teamName: teamName,
        teamMembers: teamMembers,
        specificLeagueId: specificLeagueId,
      );

      // Cache the joined league
      await localDataSource.cacheLeague(league);

      // Also update the user leagues cache
      final userLeagues = await remoteDataSource.getUserLeagues();
      await localDataSource.cacheLeagues(userLeagues);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message, data: e.data));
    }
  }

  @override
  Future<Either<Failure, League>> exitLeague({
    required String leagueId,
    required String userId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final league = await remoteDataSource.exitLeague(
        leagueId: leagueId,
        userId: userId,
      );

      // Update cache
      // We might need to update both the specific league and the user leagues list

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> updateTeamName({
    required String leagueId,
    required String userId,
    required String newName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final league = await remoteDataSource.updateTeamName(
        leagueId: leagueId,
        userId: userId,
        newName: newName,
      );

      // Update cache
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> addEvent({
    required String leagueId,
    required String name,
    required int points,
    required String creatorId,
    required String targetUserId,
    required RuleType eventType,
    String? description,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final league = await remoteDataSource.addEvent(
        leagueId: leagueId,
        name: name,
        points: points,
        creatorId: creatorId,
        targetUserId: targetUserId,
        eventType: eventType,
        description: description,
      );

      // Update cache
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> removeEvent({
    required String leagueId,
    required String eventId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final league = await remoteDataSource.removeEvent(
        leagueId: leagueId,
        eventId: eventId,
      );

      // Update cache
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> addMemory({
    required String leagueId,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final league = await remoteDataSource.addMemory(
        leagueId: leagueId,
        imageUrl: imageUrl,
        text: text,
        userId: userId,
        relatedEventId: relatedEventId,
      );

      // Update cache
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> removeMemory({
    required String leagueId,
    required String memoryId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final league = await remoteDataSource.removeMemory(
        leagueId: leagueId,
        memoryId: memoryId,
      );

      // Update cache
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Rule>>> getRules(String mode) async {
    try {
      if (!await connectionChecker.isConnected) {
        // Return cached rules when offline
        final cachedRules = await localDataSource.getCachedRules(mode);
        if (cachedRules.isNotEmpty) {
          return Right(cachedRules);
        }
        return Left(
          Failure("No internet connection and no cached rules available."),
        );
      }

      // Get from remote and cache
      final rules = await remoteDataSource.getRules(mode: mode);
      await localDataSource.cacheRules(rules, mode);
      return Right(rules);
    } on ServerException catch (e) {
      // If server error, try to get from cache
      try {
        final cachedRules = await localDataSource.getCachedRules(mode);
        if (cachedRules.isNotEmpty) {
          return Right(cachedRules);
        }
      } catch (_) {}
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
