import 'package:flutter/foundation.dart';

@immutable
class SimpleParticipant {
  final String userId;
  final String name;
  final double points;

  const SimpleParticipant({
    required this.userId,
    required this.name,
    required this.points,
  });
}
