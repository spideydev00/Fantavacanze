import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';

class MemoryModel extends Memory {
  const MemoryModel({
    required super.id,
    required super.imageUrl,
    required super.text,
    required super.createdAt,
    required super.userId,
    super.relatedEventId,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
      relatedEventId: json['relatedEventId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'relatedEventId': relatedEventId,
    };
  }
}
