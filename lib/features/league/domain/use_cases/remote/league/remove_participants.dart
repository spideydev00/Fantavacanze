import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class RemoveParticipantsParams {
  final League league;
  final List<String> participantIds;
  final String? newCaptainId;

  RemoveParticipantsParams({
    required this.league,
    required this.participantIds,
    this.newCaptainId,
  });
}

class RemoveParticipants implements Usecase<League, RemoveParticipantsParams> {
  final LeagueRepository leagueRepository;

  RemoveParticipants({required this.leagueRepository});

  @override
  Future<Either<Failure, League>> call(RemoveParticipantsParams params) async {
    if (params.newCaptainId != null) {
      debugPrint('👑 ID del nuovo capitano: ${params.newCaptainId}');
    }

    return leagueRepository.removeParticipants(
      league: params.league,
      participantIds: params.participantIds,
      newCaptainId: params.newCaptainId,
    );
  }
}
