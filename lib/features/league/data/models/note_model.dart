import 'package:fantavacanze_official/features/league/domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.participantId,
    required super.participantName,
    required super.content,
    required super.createdAt,
    required super.leagueId,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      participantId: json['participantId'] as String,
      participantName: json['participantName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      leagueId: json['leagueId'] as String, // Parse from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'leagueId': leagueId, // Add to JSON
    };
  }
}
