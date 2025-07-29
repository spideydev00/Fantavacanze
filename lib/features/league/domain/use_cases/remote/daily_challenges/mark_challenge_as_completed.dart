import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/daily_challenges_repository.dart';
import 'package:fpdart/fpdart.dart';

class MarkChallengeAsCompletedParams {
  final DailyChallenge challenge;
  final String userId;
  final League league;

  MarkChallengeAsCompletedParams({
    required this.challenge,
    required this.userId,
    required this.league,
  });
}

class MarkChallengeAsCompleted
    implements Usecase<void, MarkChallengeAsCompletedParams> {
  final DailyChallengesRepository dailyChallengesRepository;

  MarkChallengeAsCompleted({required this.dailyChallengesRepository});

  @override
  Future<Either<Failure, void>> call(
      MarkChallengeAsCompletedParams params) async {
    return await dailyChallengesRepository.markChallengeAsCompleted(
      challenge: params.challenge,
      userId: params.userId,
      league: params.league,
    );
  }
}
