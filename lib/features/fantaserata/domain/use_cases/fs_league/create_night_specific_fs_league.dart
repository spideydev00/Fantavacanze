import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class CreateNightSpecificFsLeague
    implements Usecase<FsLeague, CreateNightSpecificFsLeagueParams> {
  final FsRepository fsRepository;

  const CreateNightSpecificFsLeague(this.fsRepository);

  @override
  Future<Either<Failure, FsLeague>> call(
      CreateNightSpecificFsLeagueParams params) async {
    return await fsRepository.createNightSpecificLeague(
      name: params.name,
      description: params.description,
      creatorId: params.creatorId,
      creatorName: params.creatorName,
      nightType: params.nightType,
    );
  }
}

class CreateNightSpecificFsLeagueParams {
  final String name;
  final String? description;
  final String creatorId;
  final String creatorName;
  final FsNightType nightType;

  CreateNightSpecificFsLeagueParams({
    required this.name,
    this.description,
    required this.creatorId,
    required this.creatorName,
    required this.nightType,
  });
}
