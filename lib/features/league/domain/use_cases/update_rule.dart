import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class UpdateRule implements Usecase<League, UpdateRuleParams> {
  final LeagueRepository leagueRepository;

  UpdateRule({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(UpdateRuleParams params) async {
    return leagueRepository.updateRule(
      leagueId: params.leagueId,
      rule: params.rule,
    );
  }
}

@immutable
class UpdateRuleParams {
  final String leagueId;
  final Map<String, dynamic> rule;

  const UpdateRuleParams({
    required this.leagueId,
    required this.rule,
  });
}
