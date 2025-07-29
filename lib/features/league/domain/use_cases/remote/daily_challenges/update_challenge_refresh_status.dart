import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/daily_challenges_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateChallengeRefreshStatusParams {
  final String challengeId;
  final String userId;
  final bool isRefreshed;

  UpdateChallengeRefreshStatusParams({
    required this.challengeId,
    required this.userId,
    required this.isRefreshed,
  });
}

class UpdateChallengeRefreshStatus
    implements Usecase<void, UpdateChallengeRefreshStatusParams> {
  final DailyChallengesRepository dailyChallengesRepository;

  UpdateChallengeRefreshStatus({required this.dailyChallengesRepository});

  @override
  Future<Either<Failure, void>> call(
      UpdateChallengeRefreshStatusParams params) async {
    return await dailyChallengesRepository.updateChallengeRefreshStatus(
      challengeId: params.challengeId,
      userId: params.userId,
      isRefreshed: params.isRefreshed,
    );
  }
}
