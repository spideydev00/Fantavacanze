import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';

class RuleModel extends Rule {
  const RuleModel({
    required super.id,
    required super.name,
    required super.type,
    required super.points,
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
    RuleType ruleType = RuleType.bonus; // Default value

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
    // H A N D L E   I D   C O N V E R S I O N - IMPROVED
    int idValue = 0; // Default to 0

    if (json['id'] != null) {
      if (json['id'] is int) {
        idValue = json['id'] as int;
      } else if (json['id'] is double) {
        idValue = (json['id'] as double).toInt();
      } else if (json['id'] is String && (json['id'] as String).isNotEmpty) {
        // Try to parse string to int
        idValue = int.tryParse((json['id'] as String)) ?? 0;
      }
    }

    //----------------------------------------
    // C R E A T E   R U L E   M O D E L
    return RuleModel(
      id: idValue,
      name: json['name'] as String,
      type: ruleType,
      points: pointsValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rule_type':
          type.toString().split('.').last, // Use rule_type consistently
      'points': points, // Points already has the correct sign
    };
  }
}
