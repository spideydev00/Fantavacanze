import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_rules_repository.dart';

class UnlockFsRule implements Usecase<FsRule, UnlockFsRuleParams> {
  final FsRulesRepository repository;

  UnlockFsRule(this.repository);

  @override
  Future<Either<Failure, FsRule>> call(UnlockFsRuleParams params) async {
    return await repository.unlockRule(
      leagueId: params.leagueId,
      challengeId: params.challengeId,
    );
  }
}

class UnlockFsRuleParams {
  final String leagueId;
  final String challengeId;

  UnlockFsRuleParams({
    required this.leagueId,
    required this.challengeId,
  });
}
