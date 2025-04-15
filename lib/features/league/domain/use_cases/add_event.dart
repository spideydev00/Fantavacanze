import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
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
      creatorId: params.creatorId,
      targetUserId: params.targetUserId,
      eventType: params.eventType,
      description: params.description,
    );
  }
}

@immutable
class AddEventParams {
  final String leagueId;
  final String name;
  final int points;
  final String creatorId;
  final String targetUserId;
  final RuleType eventType;
  final String? description;

  const AddEventParams({
    required this.leagueId,
    required this.name,
    required this.points,
    required this.creatorId,
    required this.targetUserId,
    required this.eventType,
    this.description,
  });
}
