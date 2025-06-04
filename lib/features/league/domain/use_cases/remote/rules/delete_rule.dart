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
      league: params.league,
      ruleName: params.ruleName,
    );
  }
}

@immutable
class DeleteRuleParams {
  final League league;
  final String ruleName;

  const DeleteRuleParams({
    required this.league,
    required this.ruleName,
  });
}
