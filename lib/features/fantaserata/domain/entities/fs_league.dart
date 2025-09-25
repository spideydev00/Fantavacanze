import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_event.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_memory.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_participant.dart';

class FsLeague {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String inviteCode;
  final List<FsParticipant> participants;
  final List<FsEvent> events;
  final List<FsMemory> memories;

  FsLeague({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.inviteCode,
    required this.participants,
    required this.events,
    required this.memories,
  });
}
