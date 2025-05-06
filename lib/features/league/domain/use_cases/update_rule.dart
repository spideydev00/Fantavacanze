import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class UpdateRule implements Usecase<League, UpdateRuleParams> {
  final LeagueRepository leagueRepository;

  UpdateRule({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(UpdateRuleParams params) async {
    return leagueRepository.updateRule(
      league: params.league,
      rule: params.rule,
      originalRuleName: params.originalRuleName,
    );
  }
}

@immutable
class UpdateRuleParams {
  final League league;
  final Rule rule;
  final String? originalRuleName;

  const UpdateRuleParams({
    required this.league,
    required this.rule,
    this.originalRuleName,
  });
}
