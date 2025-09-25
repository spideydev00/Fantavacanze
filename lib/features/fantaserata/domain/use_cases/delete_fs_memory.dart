import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class DeleteFsMemory implements Usecase<void, DeleteFsMemoryParams> {
  final FsRepository fsRepository;

  const DeleteFsMemory(this.fsRepository);

  @override
  Future<Either<Failure, void>> call(DeleteFsMemoryParams params) async {
    return await fsRepository.deleteMemory(
      leagueId: params.leagueId,
      memoryId: params.memoryId,
    );
  }
}

class DeleteFsMemoryParams {
  final String leagueId;
  final String memoryId;

  const DeleteFsMemoryParams({
    required this.leagueId,
    required this.memoryId,
  });
}
