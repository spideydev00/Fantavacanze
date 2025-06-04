import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class UpdateTeamName implements Usecase<League, UpdateTeamNameParams> {
  final LeagueRepository leagueRepository;

  UpdateTeamName({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(UpdateTeamNameParams params) async {
    return leagueRepository.updateTeamName(
      league: params.league,
      userId: params.userId,
      newName: params.newName,
    );
  }
}

@immutable
class UpdateTeamNameParams {
  final League league;
  final String userId;
  final String newName;

  const UpdateTeamNameParams({
    required this.league,
    required this.userId,
    required this.newName,
  });
}
