import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:hive/hive.dart';

part 'rule_model.g.dart';

@HiveType(typeId: 9)
class RuleModel extends Rule {
  @HiveField(0)
  @override
  String get name => super.name;

  @HiveField(1)
  @override
  RuleType get type => super.type;

  @HiveField(2)
  @override
  double get points => super.points;

  @HiveField(3)
  @override
  DateTime get createdAt => super.createdAt;

  const RuleModel({
    required super.name,
    required super.type,
    required super.points,
    required super.createdAt,
  });

  factory RuleModel.fromJson(Map<String, dynamic> json) {
    //----------------------------------------
    // H A N D L E   P O I N T S  C O N V E R S I O N
    double pointsValue = 0.0; // Default value

    if (json['points'] != null) {
      if (json['points'] is int) {
        pointsValue = (json['points'] as int).toDouble();
      } else if (json['points'] is double) {
        pointsValue = json['points'] as double;
      }
    }

    //----------------------------------------
    // H A N D L E   R U L E   T Y P E
    RuleType ruleType = RuleType.bonus;

    // Check rule_type field first
    final typeValue = json['rule_type'] ?? json['type'];

    if (typeValue != null) {
      final typeStr = typeValue.toString().toLowerCase();

      // Ensure malus is properly detected
      if (typeStr == 'malus') {
        ruleType = RuleType.malus;
      } else if (typeStr == 'bonus') {
        ruleType = RuleType.bonus;
      } else if (pointsValue < 0) {
        // Fallback: negative points means malus
        ruleType = RuleType.malus;
      }
    } else if (pointsValue < 0) {
      // If no type specified but points are negative, it's a malus
      ruleType = RuleType.malus;
    }

    //----------------------------------------
    // C R E A T E   R U L E   M O D E L
    return RuleModel(
      createdAt: DateTime.now(),
      name: json['name'] as String,
      type: ruleType,
      points: pointsValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'rule_type': type.toString().split('.').last,
      'points': points,
    };
  }
}
