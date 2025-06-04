import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetDailyChallengesParams {
  final String userId;
  final String leagueId;

  GetDailyChallengesParams({
    required this.userId,
    required this.leagueId,
  });
}

class GetDailyChallenges
    implements Usecase<List<DailyChallenge>, GetDailyChallengesParams> {
  final LeagueRepository leagueRepository;

  GetDailyChallenges({required this.leagueRepository});

  @override
  Future<Either<Failure, List<DailyChallenge>>> call(
      GetDailyChallengesParams params) async {
    return await leagueRepository.getDailyChallenges(
      userId: params.userId,
      leagueId: params.leagueId,
    );
  }
}
