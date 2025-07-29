import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/daily_challenges_repository.dart';
import 'package:fpdart/fpdart.dart';

class RejectDailyChallengeParams {
  final String notificationId;
  final String challengeId;

  RejectDailyChallengeParams(
      {required this.notificationId, required this.challengeId});
}

class RejectDailyChallenge
    implements Usecase<void, RejectDailyChallengeParams> {
  final DailyChallengesRepository dailyChallengesRepository;

  RejectDailyChallenge({required this.dailyChallengesRepository});

  @override
  Future<Either<Failure, void>> call(RejectDailyChallengeParams params) async {
    return await dailyChallengesRepository.rejectDailyChallenge(
        params.notificationId, params.challengeId);
  }
}
