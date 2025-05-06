import 'package:equatable/equatable.dart';

enum RuleType { bonus, malus }

class Rule extends Equatable {
  final String name;
  final RuleType type;
  final double points;
  final DateTime createdAt;

  const Rule({
    required this.name,
    required this.type,
    required this.points,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [name, type, points];
}
