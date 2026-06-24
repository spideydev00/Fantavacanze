import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class JoinPartnerLeague implements Usecase<League, JoinPartnerLeagueParams> {
  final LeagueRepository leagueRepository;

  JoinPartnerLeague({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(JoinPartnerLeagueParams params) async {
    return leagueRepository.joinPartnerLeague(
      userName: params.userName,
      inviteCode: params.inviteCode,
      password: params.password,
    );
  }
}

@immutable
class JoinPartnerLeagueParams {
  final String userName;
  final String inviteCode;
  final String password;

  const JoinPartnerLeagueParams({
    required this.userName,
    required this.inviteCode,
    required this.password,
  });
}
