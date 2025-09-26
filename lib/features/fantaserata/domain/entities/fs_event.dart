import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_participant.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';

class FsEvent {
  final String id;
  final String name;
  final double points;
  final FsParticipant targetParticipant;
  final DateTime createdAt;
  final FsRuleType type;

  FsEvent({
    required this.id,
    required this.name,
    required this.points,
    required this.targetParticipant,
    required this.createdAt,
    required this.type,
  });
}
