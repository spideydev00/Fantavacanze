import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule.dart';
import 'package:hive/hive.dart';

part 'fs_rule_model.g.dart';

@HiveType(typeId: 13)
class FsRuleModel extends FsRule {
  @HiveField(0)
  @override
  String get name => super.name;

  @HiveField(1)
  @override
  double get points => super.points;

  @HiveField(2)
  @override
  FsRuleType get type => super.type;

  @HiveField(3)
  @override
  bool get isUnlocked => super.isUnlocked;

  @HiveField(4)
  @override
  bool get isCompleted => super.isCompleted;

  @HiveField(5)
  @override
  bool get isRefreshed => super.isRefreshed;

  FsRuleModel({
    required super.name,
    required super.points,
    required super.type,
    required super.isUnlocked,
    required super.isCompleted,
    required super.isRefreshed,
  });

  factory FsRuleModel.fromJson(Map<String, dynamic> json) {
    return FsRuleModel(
      name: json['name'] as String,
      points: (json['points'] as num).toDouble(),
      type: FsRuleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FsRuleType.bonus,
      ),
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      isRefreshed: json['is_refreshed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'points': points,
      'type': type.name,
      'is_unlocked': isUnlocked,
      'is_completed': isCompleted,
      'is_refreshed': isRefreshed,
    };
  }

  factory FsRuleModel.fromEntity(FsRule rule) {
    return FsRuleModel(
      name: rule.name,
      points: rule.points,
      type: rule.type,
      isUnlocked: rule.isUnlocked,
      isCompleted: rule.isCompleted,
      isRefreshed: rule.isRefreshed,
    );
  }
}

@HiveType(typeId: 14)
enum FsRuleTypeHive {
  @HiveField(0)
  bonus,
  @HiveField(1)
  malus,
}
