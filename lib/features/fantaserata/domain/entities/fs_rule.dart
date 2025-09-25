class FsRule {
  String name;
  double points;
  FsRuleType type;
  bool isUnlocked;
  bool isCompleted;
  bool isRefreshed;

  FsRule({
    required this.name,
    required this.points,
    required this.type,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isRefreshed,
  });
}

enum FsRuleType {
  bonus,
  malus,
}
