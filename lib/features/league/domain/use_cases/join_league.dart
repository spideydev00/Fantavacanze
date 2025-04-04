import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class JoinLeague implements Usecase<League, JoinLeagueParams> {
  final LeagueRepository leagueRepository;

  JoinLeague({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(JoinLeagueParams params) async {
    return leagueRepository.joinLeague(
      inviteCode: params.inviteCode,
      userId: params.userId,
      teamName: params.teamName,
      teamMembers: params.teamMembers,
      specificLeagueId: params.specificLeagueId,
    );
  }
}

@immutable
class JoinLeagueParams {
  final String inviteCode;
  final String userId;
  final String? teamName;
  final List<String>? teamMembers;
  final String? specificLeagueId;

  const JoinLeagueParams({
    required this.inviteCode,
    required this.userId,
    this.teamName,
    this.teamMembers,
    this.specificLeagueId,
  });
}
