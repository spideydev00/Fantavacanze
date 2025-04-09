import 'package:flutter/foundation.dart';

enum RuleType { bonus, malus }

@immutable
class Rule {
  final int id;
  final String name;
  final RuleType type;
  final double points;

  const Rule({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
  });
}
