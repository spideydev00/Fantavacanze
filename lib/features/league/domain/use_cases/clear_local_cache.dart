import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class ClearLocalCache implements Usecase<void, NoParams> {
  final LeagueRepository leagueRepository;

  ClearLocalCache({required this.leagueRepository});

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await leagueRepository.clearLocalCache();
  }
}
