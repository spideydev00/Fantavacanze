import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class SetRuleAsCompleted implements Usecase<void, SetRuleAsCompletedParams> {
  final FsRepository fsRepository;

  const SetRuleAsCompleted(this.fsRepository);

  @override
  Future<Either<Failure, void>> call(SetRuleAsCompletedParams params) async {
    return await fsRepository.setRuleAsCompleted(
      userId: params.userId,
      leagueId: params.leagueId,
      challengeId: params.challengeId,
      ruleName: params.ruleName,
      points: params.points,
      type: params.type,
    );
  }
}

class SetRuleAsCompletedParams {
  final String userId;
  final String leagueId;
  final String challengeId;
  final String ruleName;
  final double points;
  final String type;

  const SetRuleAsCompletedParams({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
    required this.ruleName,
    required this.points,
    required this.type,
  });
}
