import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteLeagueParams {
  final String leagueId;

  DeleteLeagueParams({required this.leagueId});
}

class DeleteLeague implements Usecase<void, DeleteLeagueParams> {
  final LeagueRepository leagueRepository;

  DeleteLeague({required this.leagueRepository});

  @override
  Future<Either<Failure, void>> call(DeleteLeagueParams params) async {
    return await leagueRepository.deleteLeague(params.leagueId);
  }
}
