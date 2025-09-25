import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';

class GetFsLeagues implements Usecase<List<FsLeague>, NoParams> {
  final FsRepository fsRepository;

  const GetFsLeagues(this.fsRepository);

  @override
  Future<Either<Failure, List<FsLeague>>> call(NoParams params) async {
    return await fsRepository.getFsLeagues();
  }
}
