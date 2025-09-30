import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_participant.dart';

class FsLeague {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String inviteCode;
  final List<FsParticipant> participants;
  final String? winnerPhotoUrl;

  FsLeague({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.inviteCode,
    required this.participants,
    this.winnerPhotoUrl,
  });
}
