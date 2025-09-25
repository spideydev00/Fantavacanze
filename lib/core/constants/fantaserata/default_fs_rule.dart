import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule.dart';

class DefaultFsRule {
  final int id;
  final String name;
  final FsRuleType type;
  final double points;

  const DefaultFsRule({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
  });

  /// Converte una DefaultFsRule in una FsRule standard
  FsRule toRule() {
    return FsRule(
      name: name,
      type: type,
      points: points,
    );
  }
}
