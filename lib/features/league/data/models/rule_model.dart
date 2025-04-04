import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';

class RuleModel extends Rule {
  const RuleModel({
    required super.name,
    required super.type,
    required super.points,
  });

  factory RuleModel.fromJson(Map<String, dynamic> json) {
    return RuleModel(
      name: json['name'] as String,
      type: RuleType.values
          .firstWhere((e) => e.toString() == 'RuleType.${json['type']}'),
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
      'points': points,
    };
  }
}
