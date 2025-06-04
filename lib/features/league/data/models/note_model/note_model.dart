import 'package:fantavacanze_official/features/league/domain/entities/note.dart';
import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 6)
class NoteModel extends Note {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get participantId => super.participantId;

  @HiveField(2)
  @override
  String get participantName => super.participantName;

  @HiveField(3)
  @override
  String get content => super.content;

  @HiveField(4)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(5)
  @override
  String get leagueId => super.leagueId;

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
      leagueId: json['leagueId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'leagueId': leagueId,
    };
  }
}
