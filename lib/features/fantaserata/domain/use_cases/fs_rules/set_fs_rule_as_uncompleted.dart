import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_rules_repository.dart';

class SetFsRuleAsUncompleted
    implements Usecase<FsRule, SetFsRuleAsUncompletedParams> {
  final FsRulesRepository repository;

  SetFsRuleAsUncompleted(this.repository);

  @override
  Future<Either<Failure, FsRule>> call(
      SetFsRuleAsUncompletedParams params) async {
    return await repository.setRuleAsUncompleted(
      leagueId: params.leagueId,
      userId: params.userId,
      challengeId: params.challengeId,
    );
  }
}

class SetFsRuleAsUncompletedParams {
  final String leagueId;
  final String userId;
  final String challengeId;

  SetFsRuleAsUncompletedParams({
    required this.leagueId,
    required this.userId,
    required this.challengeId,
  });
}
