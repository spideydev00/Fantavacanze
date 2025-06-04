import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class GetLeague implements Usecase<League, GetLeagueParams> {
  final LeagueRepository leagueRepository;

  GetLeague({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(GetLeagueParams params) async {
    return leagueRepository.getLeague(params.leagueId);
  }
}

@immutable
class GetLeagueParams {
  final String leagueId;

  const GetLeagueParams({required this.leagueId});
}
