import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/participant/fs_participant_model.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/event/fs_event_model.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/memory/fs_memory_model.dart';
import 'package:hive/hive.dart';

part 'fs_league_model.g.dart';

@HiveType(typeId: 18)
class FsLeagueModel extends FsLeague {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get name => super.name;

  @HiveField(2)
  @override
  String? get description => super.description;

  @HiveField(3)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(4)
  @override
  String get inviteCode => super.inviteCode;

  @HiveField(5)
  @override
  List<FsParticipantModel> get participants =>
      super.participants.cast<FsParticipantModel>();

  @HiveField(6)
  @override
  List<FsEventModel> get events => super.events.cast<FsEventModel>();

  @HiveField(7)
  @override
  List<FsMemoryModel> get memories => super.memories.cast<FsMemoryModel>();

  FsLeagueModel({
    required super.id,
    required super.name,
    super.description,
    required super.createdAt,
    required super.inviteCode,
    required List<FsParticipantModel> super.participants,
    required List<FsEventModel> super.events,
    required List<FsMemoryModel> super.memories,
  });

  factory FsLeagueModel.fromJson(Map<String, dynamic> json) {
    return FsLeagueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      inviteCode: json['invite_code'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((p) => FsParticipantModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>)
          .map((e) => FsEventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      memories: (json['memories'] as List<dynamic>)
          .map((m) => FsMemoryModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'invite_code': inviteCode,
      'participants': participants.map((p) => p.toJson()).toList(),
      'events': events.map((e) => e.toJson()).toList(),
      'memories': memories.map((m) => m.toJson()).toList(),
    };
  }

  factory FsLeagueModel.fromEntity(FsLeague league) {
    return FsLeagueModel(
      id: league.id,
      name: league.name,
      description: league.description,
      createdAt: league.createdAt,
      inviteCode: league.inviteCode,
      participants: league.participants
          .map((p) =>
              p is FsParticipantModel ? p : FsParticipantModel.fromEntity(p))
          .toList(),
      events: league.events
          .map((e) => e is FsEventModel ? e : FsEventModel.fromEntity(e))
          .toList(),
      memories: league.memories
          .map((m) => m is FsMemoryModel ? m : FsMemoryModel.fromEntity(m))
          .toList(),
    );
  }
}
