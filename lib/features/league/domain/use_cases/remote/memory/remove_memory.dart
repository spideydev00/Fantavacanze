import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class RemoveMemory implements Usecase<League, RemoveMemoryParams> {
  final LeagueRepository leagueRepository;

  RemoveMemory({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(RemoveMemoryParams params) async {
    return leagueRepository.removeMemory(
      league: params.league,
      memoryId: params.memoryId,
    );
  }
}

@immutable
class RemoveMemoryParams {
  final League league;
  final String memoryId;

  const RemoveMemoryParams({
    required this.league,
    required this.memoryId,
  });
}
