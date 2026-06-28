import 'package:flutter/foundation.dart';

@immutable
class GeneralRankingEntry {
  final String userId;
  final String name;
  final double points;
  final double bonusTotal;
  final double malusTotal;
  final String leagueName;

  const GeneralRankingEntry({
    required this.userId,
    required this.name,
    required this.points,
    required this.bonusTotal,
    required this.malusTotal,
    required this.leagueName,
  });
}
