import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class AddRule implements Usecase<League, AddRuleParams> {
  final LeagueRepository leagueRepository;

  AddRule({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(AddRuleParams params) async {
    return leagueRepository.addRule(
      league: params.league,
      rule: params.rule,
    );
  }
}

@immutable
class AddRuleParams {
  final League league;
  final Rule rule;

  const AddRuleParams({
    required this.league,
    required this.rule,
  });
}
