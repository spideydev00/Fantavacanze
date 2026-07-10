import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class CreatePartnerLeague
    implements Usecase<League, CreatePartnerLeagueParams> {
  final LeagueRepository leagueRepository;

  CreatePartnerLeague({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(CreatePartnerLeagueParams params) async {
    return leagueRepository.createPartnerLeague(
      userName: params.userName,
      destinationId: params.destinationId,
      name: params.name,
      password: params.password,
      roundId: params.roundId,
      description: params.description,
    );
  }
}

@immutable
class CreatePartnerLeagueParams {
  final String userName;
  final String destinationId;
  final String name;
  final String password;
  final String roundId;
  final String? description;

  const CreatePartnerLeagueParams({
    required this.userName,
    required this.destinationId,
    required this.name,
    required this.password,
    required this.roundId,
    this.description,
  });
}
