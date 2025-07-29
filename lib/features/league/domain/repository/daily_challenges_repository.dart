import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fpdart/fpdart.dart';

abstract class DailyChallengesRepository {
  // Daily Challenges operations
  Future<Either<Failure, List<DailyChallenge>>> getDailyChallenges({
    required String userId,
    required String leagueId,
  });

  Future<Either<Failure, void>> unlockDailyChallenge({
    required String challengeId,
    required String leagueId,
    required bool isUnlocked,
    int primaryPosition = 2,
  });

  Future<Either<Failure, void>> sendChallengeNotification({
    required League league,
    required DailyChallenge challenge,
    required String userId,
  });

  Future<Either<Failure, void>> markChallengeAsCompleted({
    required DailyChallenge challenge,
    required League league,
    required String userId,
  });

  Future<Either<Failure, void>> updateChallengeRefreshStatus({
    required String challengeId,
    required String userId,
    required bool isRefreshed,
  });

  Future<Either<Failure, void>> approveDailyChallenge(String notificationId);

  Future<Either<Failure, void>> rejectDailyChallenge(
    String notificationId,
    String challengeId,
  );
}
