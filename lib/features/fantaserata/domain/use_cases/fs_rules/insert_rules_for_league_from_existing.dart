import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_rules_repository.dart';

class InsertRulesForLeagueFromExisting
    implements Usecase<List<FsRule>, InsertRulesForLeagueFromExistingParams> {
  final FsRulesRepository repository;

  const InsertRulesForLeagueFromExisting(this.repository);

  @override
  Future<Either<Failure, List<FsRule>>> call(
      InsertRulesForLeagueFromExistingParams params) async {
    return await repository.insertRulesForLeagueFromExisting(
      leagueId: params.leagueId,
      name: params.name,
      points: params.points,
      typeText: params.typeText,
    );
  }
}

class InsertRulesForLeagueFromExistingParams {
  final String leagueId;
  final String name;
  final num points;
  final String typeText; // 'bonus' | 'malus'

  const InsertRulesForLeagueFromExistingParams({
    required this.leagueId,
    required this.name,
    required this.points,
    required this.typeText,
  });
}
