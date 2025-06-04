import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetRules implements Usecase<List<Rule>, String> {
  final LeagueRepository leagueRepository;

  GetRules({required this.leagueRepository});

  @override
  Future<Either<Failure, List<Rule>>> call(String mode) async {
    return leagueRepository.getRules(mode);
  }
}
