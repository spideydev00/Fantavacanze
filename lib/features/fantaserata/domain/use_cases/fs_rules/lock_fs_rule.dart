import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_rules_repository.dart';

class LockFsRule implements Usecase<FsRule, LockFsRuleParams> {
  final FsRulesRepository fsRulesRepository;

  const LockFsRule(this.fsRulesRepository);

  @override
  Future<Either<Failure, FsRule>> call(LockFsRuleParams params) async {
    return await fsRulesRepository.lockRule(
      leagueId: params.leagueId,
      challengeId: params.challengeId,
    );
  }
}

class LockFsRuleParams {
  final String leagueId;
  final String challengeId;

  const LockFsRuleParams({
    required this.leagueId,
    required this.challengeId,
  });
}
