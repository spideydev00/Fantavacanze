import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';

class FsRuleCompletion {
  final String id;
  final String userId;
  final String? userName;
  final String leagueId;
  final String challengeId;
  final String name;
  final double points;
  final FsRuleType type;
  final int? position;
  final bool isDynamic;
  final DateTime completedAt;

  const FsRuleCompletion({
    required this.id,
    required this.userId,
    this.userName,
    required this.leagueId,
    required this.challengeId,
    required this.name,
    required this.points,
    required this.type,
    this.position,
    this.isDynamic = false,
    required this.completedAt,
  });
}
