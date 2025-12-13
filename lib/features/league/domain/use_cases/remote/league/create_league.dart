import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class CreateLeague implements Usecase<League, CreateLeagueParams> {
  final LeagueRepository leagueRepository;

  CreateLeague({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(CreateLeagueParams params) async {
    return leagueRepository.createLeague(
      name: params.name,
      description: params.description,
      type: params.type,
      rules: params.rules,
    );
  }
}

@immutable
class CreateLeagueParams {
  final String name;
  final String? description;
  final LeagueType type;
  final List<Rule> rules;

  const CreateLeagueParams({
    required this.name,
    this.description,
    required this.type,
    required this.rules,
  });
}
