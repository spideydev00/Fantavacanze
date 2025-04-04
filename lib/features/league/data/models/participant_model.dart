import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:fantavacanze_official/features/league/data/models/individual_participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/team_participant_model.dart';

abstract class ParticipantModel extends Participant {
  const ParticipantModel({
    required super.name,
    required super.points,
    required super.malusTotal,
    required super.bonusTotal,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    if (type == 'individual') {
      return IndividualParticipantModel.fromJson(json);
    } else if (type == 'team') {
      return TeamParticipantModel.fromJson(json);
    } else {
      throw Exception('Unknown participant type: $type');
    }
  }

  Map<String, dynamic> toJson();
}
