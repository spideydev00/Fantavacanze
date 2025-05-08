import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemoveTeamParticipantsParams {
  final League league;
  final String teamName;
  final List<String> userIdsToRemove;
  final String requestingUserId;

  RemoveTeamParticipantsParams({
    required this.league,
    required this.teamName,
    required this.userIdsToRemove,
    required this.requestingUserId,
  });
}

class RemoveTeamParticipants
    implements Usecase<League, RemoveTeamParticipantsParams> {
  final LeagueRepository leagueRepository;

  RemoveTeamParticipants({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(RemoveTeamParticipantsParams params) {
    return leagueRepository.removeTeamParticipants(
      league: params.league,
      teamName: params.teamName,
      userIdsToRemove: params.userIdsToRemove,
      requestingUserId: params.requestingUserId,
    );
  }
}
