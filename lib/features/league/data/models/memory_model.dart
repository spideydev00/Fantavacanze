import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';

class MemoryModel extends Memory {
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
