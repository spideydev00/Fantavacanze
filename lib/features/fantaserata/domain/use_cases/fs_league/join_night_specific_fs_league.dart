import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';

class JoinNightSpecificFsLeague
    implements Usecase<FsLeague, JoinNightSpecificFsLeagueParams> {
  final FsRepository fsRepository;

  const JoinNightSpecificFsLeague(this.fsRepository);

  @override
  Future<Either<Failure, FsLeague>> call(
      JoinNightSpecificFsLeagueParams params) async {
    return await fsRepository.joinNightSpecificLeague(
      inviteCode: params.inviteCode,
      userId: params.userId,
      userName: params.userName,
    );
  }
}

class JoinNightSpecificFsLeagueParams {
  final String inviteCode;
  final String userId;
  final String userName;

  JoinNightSpecificFsLeagueParams({
    required this.inviteCode,
    required this.userId,
    required this.userName,
  });
}
