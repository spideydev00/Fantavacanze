import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

class AddMemory implements Usecase<League, AddMemoryParams> {
  final LeagueRepository leagueRepository;

  AddMemory({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(AddMemoryParams params) async {
    return leagueRepository.addMemory(
      league: params.league,
      imageUrl: params.imageUrl,
      text: params.text,
      userId: params.userId,
      relatedEventId: params.relatedEventId,
      eventName: params.eventName,
    );
  }
}

@immutable
class AddMemoryParams {
  final League league;
  final String imageUrl;
  final String text;
  final String userId;
  final String? relatedEventId;
  final String? eventName;

  const AddMemoryParams({
    required this.league,
    required this.imageUrl,
    required this.text,
    required this.userId,
    this.relatedEventId,
    this.eventName,
  });
}
