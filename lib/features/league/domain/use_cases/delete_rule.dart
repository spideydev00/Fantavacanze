import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class DeleteRule implements Usecase<League, DeleteRuleParams> {
  final LeagueRepository leagueRepository;

  DeleteRule({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(DeleteRuleParams params) async {
    return leagueRepository.deleteRule(
      leagueId: params.leagueId,
      ruleId: params.ruleId,
    );
  }
}

@immutable
class DeleteRuleParams {
  final String leagueId;
  final int ruleId;

  const DeleteRuleParams({
    required this.leagueId,
    required this.ruleId,
  });
}
