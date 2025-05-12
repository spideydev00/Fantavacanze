import 'package:flutter/foundation.dart';

@immutable
class SimpleParticipant {
  final String userId;
  final String name;

  const SimpleParticipant({
    required this.userId,
    required this.name,
  });
}
