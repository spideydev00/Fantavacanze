import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';

class GetFsLeague implements Usecase<FsLeague?, NoParams> {
  final FsRepository fsRepository;

  const GetFsLeague(this.fsRepository);

  @override
  Future<Either<Failure, FsLeague?>> call(NoParams params) async {
    return await fsRepository.getFsLeague();
  }
}
