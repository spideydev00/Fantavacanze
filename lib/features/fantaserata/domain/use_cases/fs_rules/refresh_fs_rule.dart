import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_rules_repository.dart';

class RefreshFsRule implements Usecase<FsRule, RefreshFsRuleParams> {
  final FsRulesRepository repository;

  RefreshFsRule(this.repository);

  @override
  Future<Either<Failure, FsRule>> call(RefreshFsRuleParams params) async {
    return await repository.refreshRule(
      leagueId: params.leagueId,
      challengeId: params.challengeId,
    );
  }
}

class RefreshFsRuleParams {
  final String leagueId;
  final String challengeId;

  RefreshFsRuleParams({
    required this.leagueId,
    required this.challengeId,
  });
}
