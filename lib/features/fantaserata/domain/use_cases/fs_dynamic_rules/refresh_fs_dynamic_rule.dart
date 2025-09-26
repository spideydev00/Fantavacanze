import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_dynamic_rules_repository.dart';

class RefreshFsDynamicRule
    implements Usecase<FsRule, RefreshFsDynamicRuleParams> {
  final FsDynamicRulesRepository repository;

  RefreshFsDynamicRule(this.repository);

  @override
  Future<Either<Failure, FsRule>> call(
      RefreshFsDynamicRuleParams params) async {
    return await repository.refreshRule(
      userId: params.userId,
      leagueId: params.leagueId,
      challengeId: params.challengeId,
    );
  }
}

class RefreshFsDynamicRuleParams {
  final String userId;
  final String leagueId;
  final String challengeId;

  RefreshFsDynamicRuleParams({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
  });
}
