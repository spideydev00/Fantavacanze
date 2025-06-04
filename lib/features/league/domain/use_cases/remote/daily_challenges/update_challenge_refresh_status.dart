import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
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
  final LeagueRepository leagueRepository;

  UpdateChallengeRefreshStatus({required this.leagueRepository});

  @override
  Future<Either<Failure, void>> call(
      UpdateChallengeRefreshStatusParams params) async {
    return await leagueRepository.updateChallengeRefreshStatus(
      challengeId: params.challengeId,
      userId: params.userId,
      isRefreshed: params.isRefreshed,
    );
  }
}
