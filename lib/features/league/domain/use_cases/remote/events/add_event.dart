import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class AddEvent implements Usecase<League, AddEventParams> {
  final LeagueRepository leagueRepository;

  AddEvent({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(AddEventParams params) async {
    return leagueRepository.addEvent(
      league: params.league,
      name: params.name,
      points: params.points,
      creatorId: params.creatorId,
      targetUser: params.targetUser,
      type: params.type,
      description: params.description,
      isTeamMember: params.isTeamMember,
    );
  }
}

@immutable
class AddEventParams {
  final League league;
  final String name;
  final double points;
  final String creatorId;
  final String targetUser;
  final RuleType type;
  final String? description;
  final bool isTeamMember;

  const AddEventParams({
    required this.league,
    required this.name,
    required this.points,
    required this.creatorId,
    required this.targetUser,
    required this.type,
    this.isTeamMember = false,
    this.description,
  });
}
