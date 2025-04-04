import 'package:flutter/foundation.dart';

@immutable
class Event {
  final String id;
  final String name;
  final int points;
  final String userId;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.name,
    required this.points,
    required this.userId,
    required this.createdAt,
  });
}
