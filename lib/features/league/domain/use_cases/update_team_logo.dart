import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class UpdateTeamLogo implements Usecase<League, UpdateTeamLogoParams> {
  final LeagueRepository leagueRepository;

  UpdateTeamLogo({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(UpdateTeamLogoParams params) async {
    return leagueRepository.updateTeamLogo(
      league: params.league,
      teamName: params.teamName,
      logoUrl: params.logoUrl,
    );
  }
}

@immutable
class UpdateTeamLogoParams {
  final League league;
  final String teamName;
  final String logoUrl;

  const UpdateTeamLogoParams({
    required this.league,
    required this.teamName,
    required this.logoUrl,
  });
}
