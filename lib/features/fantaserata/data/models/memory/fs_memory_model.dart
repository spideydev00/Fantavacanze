import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_memory.dart';
import 'package:hive/hive.dart';

part 'fs_memory_model.g.dart';

@HiveType(typeId: 17)
class FsMemoryModel extends FsMemory {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get imageUrl => super.imageUrl;

  @HiveField(2)
  @override
  String get description => super.description;

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

  const FsMemoryModel({
    required super.id,
    required super.imageUrl,
    required super.description,
    required super.createdAt,
    required super.userId,
    required super.participantName,
    super.relatedEventId,
    super.eventName,
  });

  factory FsMemoryModel.fromJson(Map<String, dynamic> json) {
    return FsMemoryModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
      participantName: json['participantName'] as String,
      relatedEventId: json['relatedEventId'] as String?,
      eventName: json['eventName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'participantName': participantName,
      'relatedEventId': relatedEventId,
      'eventName': eventName,
    };
  }

  factory FsMemoryModel.fromEntity(FsMemory memory) {
    return FsMemoryModel(
      id: memory.id,
      imageUrl: memory.imageUrl,
      description: memory.description,
      createdAt: memory.createdAt,
      userId: memory.userId,
      participantName: memory.participantName,
      relatedEventId: memory.relatedEventId,
      eventName: memory.eventName,
    );
  }
}
