import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemoveMemory implements Usecase<League, RemoveMemoryParams> {
  final LeagueRepository leagueRepository;

  RemoveMemory({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(RemoveMemoryParams params) async {
    return leagueRepository.removeMemory(
      leagueId: params.leagueId,
      memoryId: params.memoryId,
    );
  }
}

class RemoveMemoryParams {
  final String leagueId;
  final String memoryId;

  RemoveMemoryParams({
    required this.leagueId,
    required this.memoryId,
  });
}
