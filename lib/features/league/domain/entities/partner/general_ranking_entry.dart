import 'package:flutter/foundation.dart';

@immutable
class GeneralRankingEntry {
  final String userId;
  final String name;
  final double points;
  final String leagueName;

  const GeneralRankingEntry({
    required this.userId,
    required this.name,
    required this.points,
    required this.leagueName,
  });
}
