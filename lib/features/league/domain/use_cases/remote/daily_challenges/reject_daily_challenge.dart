import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class RejectDailyChallengeParams {
  final String notificationId;

  RejectDailyChallengeParams({required this.notificationId});
}

class RejectDailyChallenge
    implements Usecase<void, RejectDailyChallengeParams> {
  final LeagueRepository leagueRepository;

  RejectDailyChallenge({required this.leagueRepository});

  @override
  Future<Either<Failure, void>> call(RejectDailyChallengeParams params) async {
    return await leagueRepository.rejectDailyChallenge(params.notificationId);
  }
}
