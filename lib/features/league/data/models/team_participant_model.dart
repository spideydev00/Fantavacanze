import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';

class TeamParticipantModel extends TeamParticipant implements ParticipantModel {
  const TeamParticipantModel({
    required super.userIds,
    required super.name,
    required super.points,
    required super.malusTotal,
    required super.bonusTotal,
    required super.captainId,
    super.teamLogoUrl,
  });

  factory TeamParticipantModel.fromJson(Map<String, dynamic> json) {
    final double scoreValue = json['points'] is int
        ? (json['points'] as int).toDouble()
        : (json['points'] as num?)?.toDouble() ?? 0.0;

    final int malusTotalValue =
        json['malusTotal'] != null ? json['malusTotal'] as int : 0;

    final int bonusTotalValue =
        json['bonusTotal'] != null ? json['bonusTotal'] as int : 0;

    return TeamParticipantModel(
      userIds: List<String>.from(json['userIds']),
      name: json['name'] as String,
      points: scoreValue,
      captainId: json['captainId'] as String,
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
      'points': points,
      'captainId': captainId,
      'teamLogoUrl': teamLogoUrl,
      'malusTotal': malusTotal,
      'bonusTotal': bonusTotal,
    };
  }

  TeamParticipantModel copyWith({
    List<String>? userIds,
    String? name,
    double? points,
    int? malusTotal,
    int? bonusTotal,
    String? teamLogoUrl,
    String? captainId,
  }) {
    return TeamParticipantModel(
      userIds: userIds ?? this.userIds,
      name: name ?? this.name,
      points: points ?? this.points,
      malusTotal: malusTotal ?? this.malusTotal,
      bonusTotal: bonusTotal ?? this.bonusTotal,
      teamLogoUrl: teamLogoUrl ?? this.teamLogoUrl,
      captainId: captainId ?? this.captainId,
    );
  }
}
