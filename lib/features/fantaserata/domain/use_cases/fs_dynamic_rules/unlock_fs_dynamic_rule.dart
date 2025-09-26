import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_dynamic_rules_repository.dart';

class UnlockFsDynamicRule
    implements Usecase<FsRule, UnlockFsDynamicRuleParams> {
  final FsDynamicRulesRepository repository;

  UnlockFsDynamicRule(this.repository);

  @override
  Future<Either<Failure, FsRule>> call(UnlockFsDynamicRuleParams params) async {
    return await repository.unlockRule(
      userId: params.userId,
      leagueId: params.leagueId,
      challengeId: params.challengeId,
    );
  }
}

class UnlockFsDynamicRuleParams {
  final String userId;
  final String leagueId;
  final String challengeId;

  UnlockFsDynamicRuleParams({
    required this.userId,
    required this.leagueId,
    required this.challengeId,
  });
}
