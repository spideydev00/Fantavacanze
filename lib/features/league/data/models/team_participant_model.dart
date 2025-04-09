import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';

class TeamParticipantModel extends TeamParticipant implements ParticipantModel {
  const TeamParticipantModel({
    required super.userIds,
    required super.name,
    required super.points,
    required super.malusTotal,
    required super.bonusTotal,
    super.teamLogoUrl,
  });

  factory TeamParticipantModel.fromJson(Map<String, dynamic> json) {
    // Safely convert score to double
    final double scoreValue = json['score'] is int
        ? (json['score'] as int).toDouble()
        : (json['score'] as num?)?.toDouble() ?? 0.0;

    // Safely handle malusTotal and bonusTotal which might be null
    final int malusTotalValue =
        json['malusTotal'] != null ? json['malusTotal'] as int : 0;

    final int bonusTotalValue =
        json['bonusTotal'] != null ? json['bonusTotal'] as int : 0;

    return TeamParticipantModel(
      userIds: List<String>.from(json['userIds']),
      name: json['name'] as String,
      points: scoreValue,
      teamLogoUrl: json['teamLogoUrl'] as String?,
      malusTotal: malusTotalValue,
      bonusTotal: bonusTotalValue,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'team',
      'userIds': userIds,
      'name': name,
      'score': points,
      'teamLogoUrl': teamLogoUrl,
      'malusTotal': malusTotal,
      'bonusTotal': bonusTotal,
    };
  }
}
