import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
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
  final LeagueRepository leagueRepository;

  UnlockDailyChallenge({required this.leagueRepository});

  @override
  Future<Either<Failure, void>> call(UnlockDailyChallengeParams params) async {
    return await leagueRepository.unlockDailyChallenge(
      challengeId: params.challengeId,
      leagueId: params.leagueId,
      isUnlocked: params.isUnlocked,
      primaryPosition: params.primaryPosition,
    );
  }
}
