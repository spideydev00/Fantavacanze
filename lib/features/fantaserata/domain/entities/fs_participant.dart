import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule.dart';

class FsParticipant {
  final String userId;
  final String name;
  final String points;
  final String malusTotal;
  final String bonusTotal;
  final List<FsRule> rules;

  FsParticipant({
    required this.userId,
    required this.name,
    required this.points,
    required this.malusTotal,
    required this.bonusTotal,
    required this.rules,
  });
}
