import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/daily_challenges_repository.dart';
import 'package:fpdart/fpdart.dart';

class ApproveDailyChallengeParams {
  final String notificationId;

  ApproveDailyChallengeParams({required this.notificationId});
}

class ApproveDailyChallenge
    implements Usecase<void, ApproveDailyChallengeParams> {
  final DailyChallengesRepository dailyChallengesRepository;

  ApproveDailyChallenge({required this.dailyChallengesRepository});

  @override
  Future<Either<Failure, void>> call(ApproveDailyChallengeParams params) async {
    return await dailyChallengesRepository
        .approveDailyChallenge(params.notificationId);
  }
}
