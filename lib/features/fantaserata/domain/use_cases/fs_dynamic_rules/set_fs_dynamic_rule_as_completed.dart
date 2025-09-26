import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_dynamic_rules_repository.dart';

class SetFsDynamicRuleAsCompleted
    implements Usecase<FsRule, SetFsDynamicRuleAsCompletedParams> {
  final FsDynamicRulesRepository repository;

  SetFsDynamicRuleAsCompleted(this.repository);

  @override
  Future<Either<Failure, FsRule>> call(
      SetFsDynamicRuleAsCompletedParams params) async {
    return await repository.setRuleAsCompleted(
      userId: params.userId,
      leagueId: params.leagueId,
      challengeId: params.challengeId,
      ruleName: params.ruleName,
      points: params.points,
      type: params.type,
    );
  }
}

class SetFsDynamicRuleAsCompletedParams {
  final String userId;
  final String leagueId;
  final String challengeId;
  final String ruleName;
  final double points;
  final String type;

  SetFsDynamicRuleAsCompletedParams({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
    required this.ruleName,
    required this.points,
    required this.type,
  });
}
