import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';

class DefaultRule {
  final int id;
  final String name;
  final RuleType type;
  final double points;

  const DefaultRule({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
  });

  /// Converte una DefaultRule in una Rule standard
  Rule toRule() {
    return Rule(
      name: name,
      type: type,
      points: points,
      createdAt: DateTime.now(),
    );
  }
}
