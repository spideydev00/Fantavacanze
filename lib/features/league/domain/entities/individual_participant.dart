import 'package:flutter/foundation.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';

@immutable
class IndividualParticipant extends Participant {
  final String userId;

  const IndividualParticipant({
    required this.userId,
    required super.name,
    required super.points,
    required super.malusTotal,
    required super.bonusTotal,
  });
}
