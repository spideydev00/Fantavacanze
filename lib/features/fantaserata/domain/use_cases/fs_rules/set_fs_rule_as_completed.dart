import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_rules_repository.dart';

class SetFsRuleAsCompleted
    implements Usecase<Map<String, dynamic>, SetFsRuleAsCompletedParams> {
  final FsRulesRepository repository;

  SetFsRuleAsCompleted(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    SetFsRuleAsCompletedParams params,
  ) async {
    return await repository.setRuleAsCompleted(rule: params.rule);
  }
}

class SetFsRuleAsCompletedParams {
  final FsRule rule;

  SetFsRuleAsCompletedParams({
    required this.rule,
  });
}
