import 'package:flutter/foundation.dart';

@immutable
abstract class Participant {
  final String name;
  final double points;
  final int malusTotal;
  final int bonusTotal;

  const Participant({
    required this.name,
    required this.points,
    required this.malusTotal,
    required this.bonusTotal,
  });
}
