import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class AddFsEvent implements Usecase<FsLeague, AddFsEventParams> {
  final FsRepository repository;

  AddFsEvent(this.repository);

  @override
  Future<Either<Failure, FsLeague>> call(AddFsEventParams params) async {
    return await repository.addEvent(
      leagueId: params.leagueId,
      name: params.name,
      points: params.points,
      targetParticipantId: params.targetParticipantId,
      type: params.type,
    );
  }
}

class AddFsEventParams {
  final String leagueId;
  final String name;
  final double points;
  final String targetParticipantId;
  final String type;

  AddFsEventParams({
    required this.leagueId,
    required this.name,
    required this.points,
    required this.targetParticipantId,
    required this.type,
  });
}
