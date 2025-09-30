import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_rules_repository.dart';

class SetFsRuleAsCompleted
    implements Usecase<FsRule, SetFsRuleAsCompletedParams> {
  final FsRulesRepository repository;

  SetFsRuleAsCompleted(this.repository);

  @override
  Future<Either<Failure, FsRule>> call(
      SetFsRuleAsCompletedParams params) async {
    return await repository.setRuleAsCompleted(
      leagueId: params.leagueId,
      challengeId: params.challengeId,
      ruleName: params.ruleName,
      points: params.points,
      type: params.type,
    );
  }
}

class SetFsRuleAsCompletedParams {
  final String leagueId;
  final String challengeId;
  final String ruleName;
  final double points;
  final String type;

  SetFsRuleAsCompletedParams({
    required this.leagueId,
    required this.challengeId,
    required this.ruleName,
    required this.points,
    required this.type,
  });
}
