import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class DeleteFsLeague implements Usecase<void, DeleteFsLeagueParams> {
  final FsRepository fsRepository;

  const DeleteFsLeague(this.fsRepository);

  @override
  Future<Either<Failure, void>> call(DeleteFsLeagueParams params) async {
    return await fsRepository.deleteLeague(leagueId: params.leagueId);
  }
}

class DeleteFsLeagueParams {
  final String leagueId;

  const DeleteFsLeagueParams({required this.leagueId});
}
