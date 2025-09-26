import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_dynamic_rules_repository.dart';

class GetUserDynamicRules
    implements Usecase<List<FsRule>, GetUserDynamicRulesParams> {
  final FsDynamicRulesRepository repository;

  GetUserDynamicRules(this.repository);

  @override
  Future<Either<Failure, List<FsRule>>> call(
      GetUserDynamicRulesParams params) async {
    return await repository.getUserDynamicRules(
      userId: params.userId,
      leagueId: params.leagueId,
    );
  }
}

class GetUserDynamicRulesParams {
  final String userId;
  final String leagueId;

  GetUserDynamicRulesParams({
    required this.userId,
    required this.leagueId,
  });
}
