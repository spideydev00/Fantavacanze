import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/participant/fs_participant_model.dart';
import 'package:hive/hive.dart';

part 'fs_league_model.g.dart';

@HiveType(typeId: 16)
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
  String? get winnerPhotoUrl => super.winnerPhotoUrl;

  @HiveField(7)
  @override
  FsNightType get nightType => super.nightType;

  FsLeagueModel({
    required super.id,
    required super.name,
    super.description,
    required super.createdAt,
    required super.inviteCode,
    required List<FsParticipantModel> super.participants,
    super.winnerPhotoUrl,
    required super.nightType,
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
      winnerPhotoUrl: json['winner_photo_url'] as String?,
      nightType: FsNightType.fromString(json['night_type']),
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
      'winner_photo_url': winnerPhotoUrl,
      'night_type': nightType,
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
      winnerPhotoUrl: league.winnerPhotoUrl,
      nightType: league.nightType,
    );
  }
}
