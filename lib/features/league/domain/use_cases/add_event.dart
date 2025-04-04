import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class AddEvent implements Usecase<League, AddEventParams> {
  final LeagueRepository leagueRepository;

  AddEvent({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(AddEventParams params) async {
    return leagueRepository.addEvent(
      leagueId: params.leagueId,
      name: params.name,
      points: params.points,
      userId: params.userId,
      description: params.description,
    );
  }
}

@immutable
class AddEventParams {
  final String leagueId;
  final String name;
  final int points;
  final String userId;
  final String? description;

  const AddEventParams({
    required this.leagueId,
    required this.name,
    required this.points,
    required this.userId,
    this.description,
  });
}
