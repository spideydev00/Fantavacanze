import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';

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
      points: json['points'] is int
          ? (json['points'] as int).toDouble()
          : (json['points'] as num).toDouble(),
      malusTotal: json['malusTotal'] is int
          ? (json['malusTotal'] as int).toDouble()
          : (json['malusTotal'] as num?)?.toDouble() ?? 0.0,
      bonusTotal: json['bonusTotal'] is int
          ? (json['bonusTotal'] as int).toDouble()
          : (json['bonusTotal'] as num?)?.toDouble() ?? 0.0,
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

  IndividualParticipantModel copyWith({
    String? userId,
    String? name,
    double? points,
    double? malusTotal,
    double? bonusTotal,
  }) {
    return IndividualParticipantModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      points: points ?? this.points,
      malusTotal: malusTotal ?? this.malusTotal,
      bonusTotal: bonusTotal ?? this.bonusTotal,
    );
  }
}
