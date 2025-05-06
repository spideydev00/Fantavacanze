import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUsersDetails
    implements Usecase<List<Map<String, dynamic>>, List<String>> {
  final LeagueRepository leagueRepository;

  GetUsersDetails({required this.leagueRepository});

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      List<String> userIds) async {
    return leagueRepository.getUsersDetails(userIds);
  }
}
