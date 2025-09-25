import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/repository/fs_repository.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';

class JoinFsLeague implements Usecase<FsLeague, JoinFsLeagueParams> {
  final FsRepository fsRepository;

  const JoinFsLeague(this.fsRepository);

  @override
  Future<Either<Failure, FsLeague>> call(JoinFsLeagueParams params) async {
    return await fsRepository.joinLeague(
      inviteCode: params.inviteCode,
      userId: params.userId,
      userName: params.userName,
    );
  }
}

class JoinFsLeagueParams {
  final String inviteCode;
  final String userId;
  final String userName;

  const JoinFsLeagueParams({
    required this.inviteCode,
    required this.userId,
    required this.userName,
  });
}
