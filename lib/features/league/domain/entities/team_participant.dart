import 'package:flutter/foundation.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';

@immutable
class TeamParticipant extends Participant {
  final List<String> userIds;
  final String? teamLogoUrl;

  const TeamParticipant({
    required this.userIds,
    required super.name,
    required super.points,
    required super.malusTotal,
    required super.bonusTotal,
    this.teamLogoUrl,
  });
}
