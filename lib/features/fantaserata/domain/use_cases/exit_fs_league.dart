import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class ExitFsLeague implements Usecase<void, ExitFsLeagueParams> {
  final FsRepository fsRepository;

  const ExitFsLeague(this.fsRepository);

  @override
  Future<Either<Failure, void>> call(ExitFsLeagueParams params) async {
    return await fsRepository.exitLeague(
      leagueId: params.leagueId,
      userId: params.userId,
    );
  }
}

class ExitFsLeagueParams {
  final String leagueId;
  final String userId;

  const ExitFsLeagueParams({
    required this.leagueId,
    required this.userId,
  });
}
