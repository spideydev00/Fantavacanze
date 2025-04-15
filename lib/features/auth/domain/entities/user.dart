import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String email;
  final String name;
  final bool isPremium;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.isPremium = false,
  });
}
