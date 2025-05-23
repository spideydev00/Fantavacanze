import 'package:fantavacanze_official/features/league/domain/entities/simple_participant.dart';

class SimpleParticipantModel extends SimpleParticipant {
  const SimpleParticipantModel({
    required super.userId,
    required super.name,
    required super.points,
  });

  factory SimpleParticipantModel.fromJson(Map<String, dynamic> json) {
    return SimpleParticipantModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'points': points,
    };
  }

  SimpleParticipantModel copyWith({
    String? userId,
    String? name,
    double? points,
  }) {
    return SimpleParticipantModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      points: points ?? this.points,
    );
  }
}
