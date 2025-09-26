import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_event.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/participant/fs_participant_model.dart';
import 'package:hive/hive.dart';

part 'fs_event_model.g.dart';

@HiveType(typeId: 16)
class FsEventModel extends FsEvent {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get name => super.name;

  @HiveField(2)
  @override
  double get points => super.points;

  @HiveField(3)
  @override
  FsParticipantModel get targetParticipant =>
      super.targetParticipant as FsParticipantModel;

  @HiveField(4)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(5)
  @override
  FsRuleType get type => super.type;

  FsEventModel({
    required super.id,
    required super.name,
    required super.points,
    required FsParticipantModel super.targetParticipant,
    required super.createdAt,
    required super.type,
  });

  factory FsEventModel.fromJson(Map<String, dynamic> json) {
    return FsEventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      points: (json['points'] as num).toDouble(),
      targetParticipant: FsParticipantModel.fromJson(
          json['targetParticipant'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: FsRuleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FsRuleType.bonus,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'targetParticipant':
          FsParticipantModel.fromEntity(targetParticipant).toJson(),
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
    };
  }

  factory FsEventModel.fromEntity(FsEvent event) {
    return FsEventModel(
      id: event.id,
      name: event.name,
      points: event.points,
      targetParticipant: event.targetParticipant is FsParticipantModel
          ? event.targetParticipant as FsParticipantModel
          : FsParticipantModel.fromEntity(event.targetParticipant),
      createdAt: event.createdAt,
      type: event.type,
    );
  }
}
