import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:hive/hive.dart';

part 'memory_model.g.dart';

@HiveType(typeId: 5)
class MemoryModel extends Memory {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get imageUrl => super.imageUrl;

  @HiveField(2)
  @override
  String get text => super.text;

  @HiveField(3)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(4)
  @override
  String get userId => super.userId;

  @HiveField(5)
  @override
  String get participantName => super.participantName;

  @HiveField(6)
  @override
  String? get relatedEventId => super.relatedEventId;

  @HiveField(7)
  @override
  String? get eventName => super.eventName;

  const MemoryModel({
    required super.id,
    required super.imageUrl,
    required super.text,
    required super.createdAt,
    required super.userId,
    required super.participantName,
    super.relatedEventId,
    super.eventName,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
      participantName: json['participantName'] as String? ?? 'Unknown',
      relatedEventId: json['relatedEventId'] as String?,
      eventName: json['eventName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'participantName': participantName,
      'relatedEventId': relatedEventId,
      'eventName': eventName,
    };
  }
}
