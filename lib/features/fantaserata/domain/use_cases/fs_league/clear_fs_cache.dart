import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class ClearFsCache implements Usecase<void, NoParams> {
  final FsRepository fsRepository;

  const ClearFsCache(this.fsRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await fsRepository.clearFsLeagueCache();
  }
}
