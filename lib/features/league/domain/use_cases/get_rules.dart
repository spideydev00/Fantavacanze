import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetRules implements Usecase<List<Rule>, String> {
  final LeagueRepository leagueRepository;

  GetRules({required this.leagueRepository});

  @override
  Future<Either<Failure, List<Rule>>> call(String mode) async {
    if (mode != "hard" && mode != "soft") {
      return Left(Failure("Invalid mode. Use 'hard' or 'soft'"));
    }
    return leagueRepository.getRules(mode);
  }
}
