import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';

class DefaultFsRule {
  final int id;
  final String name;
  final FsRuleType type;
  final double points;
  final bool isCompleted;

  const DefaultFsRule({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
    this.isCompleted = false,
  });
}
