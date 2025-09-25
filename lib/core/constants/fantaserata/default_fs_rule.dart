import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule.dart';

class DefaultFsRule {
  final int id;
  final String name;
  final FsRuleType type;
  final double points;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isRefreshed;

  const DefaultFsRule({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
    this.isUnlocked = true,
    this.isCompleted = false,
    this.isRefreshed = true,
  });

  /// Converte una DefaultFsRule in una FsRule standard
  FsRule toRule() {
    return FsRule(
      name: name,
      type: type,
      points: points,
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
      isRefreshed: isRefreshed,
    );
  }
}
