import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_event.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_memory.dart';
import 'package:fantavacanze_official/features/fantaserata/data/datasources/remote/fs_remote_data_source.dart';
import 'package:fantavacanze_official/features/fantaserata/data/datasources/local/fs_local_data_source.dart';

class FsRepositoryImpl implements FsRepository {
  final FsRemoteDataSource remoteDataSource;
  final FsLocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  const FsRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, FsLeague>> createLeague({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final league = await remoteDataSource.createLeague(
        name: name,
        description: description,
        creatorId: creatorId,
        creatorName: creatorName,
      );

      // Update cache
      try {
        await localDataSource.cacheFsLeague(league);
      } catch (e) {
        // Cache update failure shouldn't fail the operation
      }

      return right(league);
    });
  }

  @override
  Future<Either<Failure, FsLeague>> joinLeague({
    required String inviteCode,
    required String userId,
    required String userName,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final league = await remoteDataSource.joinLeague(
        inviteCode: inviteCode,
        userId: userId,
        userName: userName,
      );

      // Update cache
      try {
        await localDataSource.cacheFsLeague(league);
      } catch (e) {
        // Cache update failure shouldn't fail the operation
      }

      return right(league);
    });
  }

  @override
  Future<Either<Failure, FsEvent>> addEvent({
    required String leagueId,
    required String name,
    required double points,
    required String targetParticipantId,
    required String type,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final event = await remoteDataSource.addEvent(
        leagueId: leagueId,
        name: name,
        points: points,
        targetParticipantId: targetParticipantId,
        type: type,
      );

      return right(event);
    });
  }

  @override
  Future<Either<Failure, void>> removeEvent({
    required String leagueId,
    required String eventId,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      await remoteDataSource.removeEvent(
        leagueId: leagueId,
        eventId: eventId,
      );

      return right(null);
    });
  }

  @override
  Future<Either<Failure, FsMemory>> addMemory({
    required String leagueId,
    required String imageUrl,
    required String description,
    required String userId,
    required String participantName,
    String? relatedEventId,
    String? eventName,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      final memory = await remoteDataSource.addMemory(
        leagueId: leagueId,
        imageUrl: imageUrl,
        description: description,
        userId: userId,
        participantName: participantName,
        relatedEventId: relatedEventId,
        eventName: eventName,
      );

      return right(memory);
    });
  }

  @override
  Future<Either<Failure, void>> deleteMemory({
    required String leagueId,
    required String memoryId,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      await remoteDataSource.deleteMemory(
        leagueId: leagueId,
        memoryId: memoryId,
      );

      return right(null);
    });
  }

  @override
  Future<Either<Failure, void>> removeParticipant({
    required String leagueId,
    required String participantId,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      await remoteDataSource.removeParticipant(
        leagueId: leagueId,
        participantId: participantId,
      );

      return right(null);
    });
  }

  @override
  Future<Either<Failure, void>> exitLeague({
    required String leagueId,
    required String userId,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      await remoteDataSource.exitLeague(
        leagueId: leagueId,
        userId: userId,
      );

      // Clear cache since user exited
      try {
        await localDataSource.clearFsLeagueCache();
      } catch (e) {
        // Cache update failure shouldn't fail the operation
      }

      return right(null);
    });
  }

  @override
  Future<Either<Failure, void>> deleteLeague({
    required String leagueId,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      await remoteDataSource.deleteLeague(leagueId: leagueId);

      // Clear cache since league is deleted
      try {
        await localDataSource.clearFsLeagueCache();
      } catch (e) {
        // Cache update failure shouldn't fail the operation
      }

      return right(null);
    });
  }

  @override
  Future<Either<Failure, void>> refreshRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      await remoteDataSource.refreshRule(
        userId: userId,
        leagueId: leagueId,
        challengeId: challengeId,
      );

      return right(null);
    });
  }

  @override
  Future<Either<Failure, void>> unlockRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      await remoteDataSource.unlockRule(
        userId: userId,
        leagueId: leagueId,
        challengeId: challengeId,
      );

      return right(null);
    });
  }

  @override
  Future<Either<Failure, void>> setRuleAsCompleted({
    required String userId,
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  }) async {
    return _tryDatabaseOperation(() async {
      if (!await connectionChecker.isConnected) {
        return left(const Failure('Nessuna connessione internet'));
      }

      await remoteDataSource.setRuleAsCompleted(
        userId: userId,
        leagueId: leagueId,
        challengeId: challengeId,
        ruleName: ruleName,
        points: points,
        type: type,
      );

      return right(null);
    });
  }

  @override
  Future<Either<Failure, FsLeague?>> getFsLeague() async {
    return _tryDatabaseOperation(() async {
      try {
        // Try cache first
        final cachedLeague = await localDataSource.getCachedFsLeague();

        // If connected, fetch fresh data
        if (await connectionChecker.isConnected) {
          try {
            final remoteLeague = await remoteDataSource.getFsLeague();
            if (remoteLeague != null) {
              await localDataSource.cacheFsLeague(remoteLeague);
              return right(remoteLeague);
            } else {
              // No remote league, clear cache and return null
              await localDataSource.clearFsLeagueCache();
              return right(null);
            }
          } catch (e) {
            // If remote fails but we have cache, return cache
            return right(cachedLeague);
          }
        }

        // Return cached data
        return right(cachedLeague);
      } catch (e) {
        // If everything fails, return null
        return right(null);
      }
    });
  }

  Future<Either<Failure, T>> _tryDatabaseOperation<T>(
    Future<Either<Failure, T>> Function() operation,
  ) async {
    try {
      return await operation();
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } on CacheException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
