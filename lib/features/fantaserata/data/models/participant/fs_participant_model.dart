import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_participant.dart';
import 'package:hive/hive.dart';

part 'fs_participant_model.g.dart';

@HiveType(typeId: 15)
class FsParticipantModel extends FsParticipant {
  @HiveField(0)
  @override
  String get userId => super.userId;

  @HiveField(1)
  @override
  String get name => super.name;

  @HiveField(2)
  @override
  double get points => super.points;

  @HiveField(3)
  @override
  double get malusTotal => super.malusTotal;

  @HiveField(4)
  @override
  double get bonusTotal => super.bonusTotal;

  FsParticipantModel({
    required super.userId,
    required super.name,
    required super.points,
    required super.malusTotal,
    required super.bonusTotal,
  });

  factory FsParticipantModel.fromJson(Map<String, dynamic> json) {
    return FsParticipantModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      points: (json['points'] as num).toDouble(),
      malusTotal: (json['malusTotal'] as num).toDouble(),
      bonusTotal: (json['bonusTotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'points': points,
      'malusTotal': malusTotal,
      'bonusTotal': bonusTotal,
    };
  }

  factory FsParticipantModel.fromEntity(FsParticipant participant) {
    return FsParticipantModel(
      userId: participant.userId,
      name: participant.name,
      points: participant.points,
      malusTotal: participant.malusTotal,
      bonusTotal: participant.bonusTotal,
    );
  }
}
