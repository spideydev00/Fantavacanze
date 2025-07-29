import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/league/data/datasources/local/local_data_source.dart';
import 'package:fantavacanze_official/features/league/data/datasources/remote/daily_challenges_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/data/models/daily_challenge_model/daily_challenge_model.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model/league_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/daily_challenges_repository.dart';
import 'package:fpdart/fpdart.dart';

class DailyChallengesRepositoryImpl implements DailyChallengesRepository {
  final DailyChallengesRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  DailyChallengesRepositoryImpl({
    required this.remoteDataSource,
    required this.connectionChecker,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<DailyChallenge>>> getDailyChallenges({
    required String userId,
    required String leagueId,
  }) async {
    try {
      final cachedChallenges =
          await localDataSource.getCachedDailyChallenges(leagueId);

      if (cachedChallenges.isNotEmpty) {
        // Check if cached challenges need refresh (passed 7 AM)
        final now = DateTime.now();
        final today7AM = DateTime(now.year, now.month, now.day, 7, 0);

        // Get the first challenge to check its creation date
        final challenge = cachedChallenges.first;

        // If it's past 7 AM and the challenge was created before today at 7 AM,
        // we need to refresh the challenges
        bool needsRefresh =
            now.isAfter(today7AM) && challenge.createdAt.isBefore(today7AM);

        if (!needsRefresh) {
          return Right(cachedChallenges);
        } else if (!await connectionChecker.isConnected) {
          // If we need refresh but have no connection, use cache anyway
          return Right(cachedChallenges);
        }
      } else if (!await connectionChecker.isConnected) {
        return Left(
            Failure('❌ Nessuna connessione e nessun dato nella cache.'));
      }

      // Get from remote and cache
      final challenges = await remoteDataSource.getDailyChallenges(
        userId: userId,
        leagueId: leagueId,
      );

      await localDataSource.cacheDailyChallenges(challenges, leagueId);

      return Right(challenges);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> unlockDailyChallenge({
    required String challengeId,
    required String leagueId,
    required bool isUnlocked,
    int primaryPosition = 2,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      final res = await remoteDataSource.unlockDailyChallenge(
        challengeId: challengeId,
        isUnlocked: isUnlocked,
        leagueId: leagueId,
        primaryPosition: primaryPosition,
      );

      // Update the challenges in the cache
      final cachedChallenges =
          await localDataSource.getCachedDailyChallenges(leagueId);

      // Calculate substitute position
      final substitutePosition = primaryPosition + 3;

      // Update both the primary challenge by ID and any challenge at the substitute position
      final updatedChallenges = cachedChallenges.map((cachedChallenge) {
        // Update specific challenge by ID
        if (cachedChallenge.id == challengeId) {
          return cachedChallenge.copyWith(isUnlocked: isUnlocked);
        }

        // Also update the substitute challenge at position + 3
        if (cachedChallenge.position == substitutePosition) {
          return cachedChallenge.copyWith(isUnlocked: isUnlocked);
        }

        return cachedChallenge;
      }).toList();

      await localDataSource.cacheDailyChallenges(updatedChallenges, leagueId);

      return Right(res);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendChallengeNotification({
    required League league,
    required DailyChallenge challenge,
    required String userId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      await remoteDataSource.sendChallengeNotification(
        league: league as LeagueModel,
        challenge: challenge as DailyChallengeModel,
        userId: userId,
      );

      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> markChallengeAsCompleted({
    required DailyChallenge challenge,
    required League league,
    required String userId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      await remoteDataSource.markChallengeAsCompleted(
        challenge: challenge as DailyChallengeModel,
        userId: userId,
        league: league as LeagueModel,
      );

      // Update the challenge in the cache
      final cachedChallenges =
          await localDataSource.getCachedDailyChallenges(league.id);

      final updatedChallenges = cachedChallenges.map((cachedChallenge) {
        if (cachedChallenge.id == challenge.id) {
          return cachedChallenge.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }
        return cachedChallenge;
      }).toList();

      await localDataSource.cacheDailyChallenges(updatedChallenges, league.id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> approveDailyChallenge(
      String notificationId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      // Approve on server
      await remoteDataSource.approveDailyChallenge(notificationId);

      // Delete from cache since it's been processed
      await localDataSource.deleteNotificationFromCache(notificationId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectDailyChallenge(
    String notificationId,
    String challengeId,
  ) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      // Reject on server
      await remoteDataSource.rejectDailyChallenge(notificationId, challengeId);

      // Delete from cache since it's been processed
      await localDataSource.deleteNotificationFromCache(notificationId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateChallengeRefreshStatus({
    required String challengeId,
    required String userId,
    required bool isRefreshed,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      // 1. Update on the server
      await remoteDataSource.updateChallengeRefreshStatus(
        challengeId: challengeId,
        userId: userId,
        isRefreshed: isRefreshed,
      );

      // 2. Find which league this challenge belongs to
      final leagueId =
          await localDataSource.findLeagueIdForChallenge(challengeId);

      if (leagueId.isNotEmpty) {
        // 3. Update in cache
        await localDataSource.updateCachedChallenge(
            challengeId, leagueId, isRefreshed);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }
}
