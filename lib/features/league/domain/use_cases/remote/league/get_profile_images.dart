import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/member_profile.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetProfileImages
    implements Usecase<List<MemberProfile>, GetProfileImagesParams> {
  final LeagueRepository leagueRepository;

  GetProfileImages({required this.leagueRepository});

  @override
  Future<Either<Failure, List<MemberProfile>>> call(
    GetProfileImagesParams params,
  ) async {
    return await leagueRepository.getProfileImagesForUsers(params.userIds);
  }
}

class GetProfileImagesParams {
  final List<String> userIds;

  const GetProfileImagesParams({required this.userIds});
}
