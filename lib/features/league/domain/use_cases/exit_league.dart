import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class ExitLeague implements Usecase<League, ExitLeagueParams> {
  final LeagueRepository leagueRepository;

  ExitLeague({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(ExitLeagueParams params) async {
    return leagueRepository.exitLeague(
      leagueId: params.leagueId,
      userId: params.userId,
    );
  }
}

@immutable
class ExitLeagueParams {
  final String leagueId;
  final String userId;

  const ExitLeagueParams({
    required this.leagueId,
    required this.userId,
  });
}
