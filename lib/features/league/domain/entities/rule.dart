import 'package:equatable/equatable.dart';

enum RuleType { bonus, malus }

class Rule extends Equatable {
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

  @override
  List<Object?> get props => [id, name, type, points];
}
