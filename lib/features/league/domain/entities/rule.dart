import 'package:flutter/foundation.dart';

enum RuleType { bonus, malus }

@immutable
class Rule {
  final String name;
  final RuleType type;
  final int points;

  const Rule({
    required this.name,
    required this.type,
    required this.points,
  });
}
