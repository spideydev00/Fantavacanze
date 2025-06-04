import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class SendChallengeNotificationParams {
  final League league;
  final DailyChallenge challenge;
  final String userId;

  SendChallengeNotificationParams({
    required this.league,
    required this.challenge,
    required this.userId,
  });
}

class SendChallengeNotification
    implements Usecase<void, SendChallengeNotificationParams> {
  final LeagueRepository leagueRepository;

  SendChallengeNotification({required this.leagueRepository});

  @override
  Future<Either<Failure, void>> call(
    SendChallengeNotificationParams params,
  ) async {
    return await leagueRepository.sendChallengeNotification(
      league: params.league,
      challenge: params.challenge,
      userId: params.userId,
    );
  }
}
