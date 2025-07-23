import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemoveEvent implements Usecase<League, RemoveEventParams> {
  final LeagueRepository leagueRepository;

  RemoveEvent({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(RemoveEventParams params) async {
    return await leagueRepository.removeEvent(
      league: params.league,
      eventId: params.eventId,
    );
  }
}

class RemoveEventParams {
  final League league;
  final String eventId;

  RemoveEventParams({
    required this.league,
    required this.eventId,
  });
}
