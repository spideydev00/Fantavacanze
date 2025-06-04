import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateLeagueInfoParams {
  final League league;
  final String? name;
  final String? description;

  UpdateLeagueInfoParams({
    required this.league,
    this.name,
    this.description,
  });
}

class UpdateLeagueInfo implements Usecase<League, UpdateLeagueInfoParams> {
  final LeagueRepository leagueRepository;

  UpdateLeagueInfo({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(UpdateLeagueInfoParams params) async {
    return leagueRepository.updateLeagueInfo(
      league: params.league,
      name: params.name,
      description: params.description,
    );
  }
}
