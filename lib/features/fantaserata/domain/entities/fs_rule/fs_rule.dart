import 'package:hive/hive.dart';

part 'fs_rule.g.dart';

@HiveType(typeId: 14)
enum FsRuleType {
  @HiveField(0)
  bonus,

  @HiveField(1)
  malus
}

class FsRule {
  String id;
  String userId;
  String? userName;
  String leagueId;
  String challengeId;
  String name;
  double points;
  FsRuleType type;
  double position;
  bool isCompleted;
  bool isRefreshed;
  bool isUnlocked;
  DateTime createdAt;
  DateTime? completedAt;
  DateTime? refreshedAt;

  FsRule({
    required this.id,
    required this.userId,
    this.userName,
    required this.leagueId,
    required this.challengeId,
    required this.name,
    required this.points,
    required this.type,
    required this.position,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isRefreshed,
    required this.createdAt,
    this.completedAt,
    this.refreshedAt,
  });
}
