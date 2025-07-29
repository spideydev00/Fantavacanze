import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/daily_challenges_repository.dart';
import 'package:fpdart/fpdart.dart';

class UnlockDailyChallengeParams {
  final String challengeId;
  final String leagueId;
  final bool isUnlocked;
  final int primaryPosition;

  UnlockDailyChallengeParams({
    required this.challengeId,
    required this.leagueId,
    required this.isUnlocked,
    this.primaryPosition = 2,
  });
}

class UnlockDailyChallenge
    implements Usecase<void, UnlockDailyChallengeParams> {
  final DailyChallengesRepository dailyChallengesRepository;

  UnlockDailyChallenge({required this.dailyChallengesRepository});

  @override
  Future<Either<Failure, void>> call(UnlockDailyChallengeParams params) async {
    return await dailyChallengesRepository.unlockDailyChallenge(
      challengeId: params.challengeId,
      leagueId: params.leagueId,
      isUnlocked: params.isUnlocked,
      primaryPosition: params.primaryPosition,
    );
  }
}
