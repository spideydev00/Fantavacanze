import 'package:fantavacanze_official/features/league/domain/entities/simple_participant.dart';

class SimpleParticipantModel extends SimpleParticipant {
  const SimpleParticipantModel({
    required super.userId,
    required super.name,
  });

  factory SimpleParticipantModel.fromJson(Map<String, dynamic> json) {
    return SimpleParticipantModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
    };
  }
}
