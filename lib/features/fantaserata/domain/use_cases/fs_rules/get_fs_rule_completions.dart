import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule_completion.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_rules_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetFsRuleCompletions
    implements Usecase<List<FsRuleCompletion>, GetFsRuleCompletionsParams> {
  final FsRulesRepository repository;

  GetFsRuleCompletions(this.repository);

  @override
  Future<Either<Failure, List<FsRuleCompletion>>> call(
      GetFsRuleCompletionsParams params) {
    return repository.getRuleCompletions(leagueId: params.leagueId);
  }
}

class GetFsRuleCompletionsParams {
  final String leagueId;

  GetFsRuleCompletionsParams({required this.leagueId});
}
