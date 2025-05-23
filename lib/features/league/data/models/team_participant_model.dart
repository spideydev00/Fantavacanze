import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/simple_participant_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';

class TeamParticipantModel extends TeamParticipant implements ParticipantModel {
  const TeamParticipantModel({
    required super.members,
    required super.name,
    required super.points,
    required super.malusTotal,
    required super.bonusTotal,
    required super.captainId,
    super.teamLogoUrl,
  });

  factory TeamParticipantModel.fromJson(Map<String, dynamic> json) {
    return TeamParticipantModel(
      members: (json['members'] as List<dynamic>)
          .map(
              (e) => SimpleParticipantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      points: json['points'] is int
          ? (json['points'] as int).toDouble()
          : (json['points'] as num).toDouble(),
      malusTotal: json['malusTotal'] is int
          ? (json['malusTotal'] as int).toDouble()
          : (json['malusTotal'] as num?)?.toDouble() ?? 0.0,
      bonusTotal: json['bonusTotal'] is int
          ? (json['bonusTotal'] as int).toDouble()
          : (json['bonusTotal'] as num?)?.toDouble() ?? 0.0,
      captainId: json['captainId'] as String,
      teamLogoUrl: json['teamLogoUrl'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'team',
      'members':
          members.map((e) => (e as SimpleParticipantModel).toJson()).toList(),
      'name': name,
      'points': points,
      'malusTotal': malusTotal,
      'bonusTotal': bonusTotal,
      'captainId': captainId,
      'teamLogoUrl': teamLogoUrl,
    };
  }

  TeamParticipantModel copyWith({
    List<SimpleParticipantModel>? members,
    String? name,
    double? points,
    double? malusTotal,
    double? bonusTotal,
    String? captainId,
    String? teamLogoUrl,
  }) {
    return TeamParticipantModel(
      members: members ??
          this.members.map((e) => e as SimpleParticipantModel).toList(),
      name: name ?? this.name,
      points: points ?? this.points,
      malusTotal: malusTotal ?? this.malusTotal,
      bonusTotal: bonusTotal ?? this.bonusTotal,
      captainId: captainId ?? this.captainId,
      teamLogoUrl: teamLogoUrl ?? this.teamLogoUrl,
    );
  }
}
