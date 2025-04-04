import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';

class IndividualParticipantModel extends IndividualParticipant
    implements ParticipantModel {
  const IndividualParticipantModel({
    required super.userId,
    required super.name,
    required super.points,
    required super.malusTotal,
    required super.bonusTotal,
  });

  factory IndividualParticipantModel.fromJson(Map<String, dynamic> json) {
    return IndividualParticipantModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      points: json['score'] as double,
      malusTotal: json['malusTotal'] as int,
      bonusTotal: json['bonusTotal'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'individual',
      'userId': userId,
      'name': name,
      'score': points,
      'malusTotal': malusTotal,
      'bonusTotal': bonusTotal,
    };
  }
}
