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
    return TeamParticipantModel(
      userIds: List<String>.from(json['userIds']),
      name: json['name'] as String,
      points: json['points'] as double,
      teamLogoUrl: json['teamLogoUrl'] as String?,
      malusTotal: json['malusTotal'] as int,
      bonusTotal: json['bonusTotal'] as int,
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
