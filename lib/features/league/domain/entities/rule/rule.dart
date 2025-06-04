import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'rule.g.dart';

@HiveType(typeId: 12)
enum RuleType {
  @HiveField(0)
  bonus,

  @HiveField(1)
  malus
}

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
