import 'package:fantavacanze_official/features/league/domain/entities/simple_participant.dart';
import 'package:hive/hive.dart';

part 'simple_participant_model.g.dart';

@HiveType(typeId: 10)
class SimpleParticipantModel extends SimpleParticipant {
  @HiveField(0)
  @override
  String get userId => super.userId;

  @HiveField(1)
  @override
  String get name => super.name;

  @HiveField(2)
  @override
  double get points => super.points;

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
