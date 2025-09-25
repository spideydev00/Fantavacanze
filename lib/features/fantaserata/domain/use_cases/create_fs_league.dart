import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';

class CreateFsLeague implements Usecase<FsLeague, CreateFsLeagueParams> {
  final FsRepository fsRepository;

  const CreateFsLeague(this.fsRepository);

  @override
  Future<Either<Failure, FsLeague>> call(CreateFsLeagueParams params) async {
    return await fsRepository.createLeague(
      name: params.name,
      description: params.description,
      creatorId: params.creatorId,
      creatorName: params.creatorName,
    );
  }
}

class CreateFsLeagueParams {
  final String name;
  final String? description;
  final String creatorId;
  final String creatorName;

  const CreateFsLeagueParams({
    required this.name,
    this.description,
    required this.creatorId,
    required this.creatorName,
  });
}
