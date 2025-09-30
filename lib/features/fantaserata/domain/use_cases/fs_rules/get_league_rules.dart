import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_rules_repository.dart';

class GetLeagueRules implements Usecase<List<FsRule>, GetLeagueRulesParams> {
  final FsRulesRepository repository;

  const GetLeagueRules(this.repository);

  @override
  Future<Either<Failure, List<FsRule>>> call(
      GetLeagueRulesParams params) async {
    return await repository.getLeagueRules(
      leagueId: params.leagueId,
    );
  }
}

class GetLeagueRulesParams {
  final String leagueId;

  const GetLeagueRulesParams({
    required this.leagueId,
  });
}
