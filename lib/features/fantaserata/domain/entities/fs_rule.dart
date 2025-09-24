class FsRule {
  String name;
  String points;
  FsRuleType type;

  FsRule({
    required this.name,
    required this.points,
    required this.type,
  });
}

enum FsRuleType {
  bonus,
  malus,
}
