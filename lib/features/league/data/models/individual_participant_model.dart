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
    // Handle numeric conversion with null-safety
    double pointsValue;
    if (json['points'] != null) {
      pointsValue = json['points'] is int
          ? (json['points'] as int).toDouble()
          : (json['points'] as num).toDouble();
    } else {
      pointsValue = 0.0;
    }

    // Safely handle malusTotal and bonusTotal which might be null
    final int malusTotalValue =
        json['malusTotal'] != null ? json['malusTotal'] as int : 0;

    final int bonusTotalValue =
        json['bonusTotal'] != null ? json['bonusTotal'] as int : 0;

    return IndividualParticipantModel(
      userId: json['userId'] as String,
      name: json['name'] as String? ?? "Utente senza nome",
      points: pointsValue,
      malusTotal: malusTotalValue,
      bonusTotal: bonusTotalValue,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'individual',
      'userId': userId,
      'name': name,
      'points': points,
      'malusTotal': malusTotal,
      'bonusTotal': bonusTotal,
    };
  }
}
