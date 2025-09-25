import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_memory.dart';

class AddFsMemory implements Usecase<FsMemory, AddFsMemoryParams> {
  final FsRepository fsRepository;

  const AddFsMemory(this.fsRepository);

  @override
  Future<Either<Failure, FsMemory>> call(AddFsMemoryParams params) async {
    return await fsRepository.addMemory(
      leagueId: params.leagueId,
      imageUrl: params.imageUrl,
      description: params.description,
      userId: params.userId,
      participantName: params.participantName,
      relatedEventId: params.relatedEventId,
      eventName: params.eventName,
    );
  }
}

class AddFsMemoryParams {
  final String leagueId;
  final String imageUrl;
  final String description;
  final String userId;
  final String participantName;
  final String? relatedEventId;
  final String? eventName;

  const AddFsMemoryParams({
    required this.leagueId,
    required this.imageUrl,
    required this.description,
    required this.userId,
    required this.participantName,
    this.relatedEventId,
    this.eventName,
  });
}
