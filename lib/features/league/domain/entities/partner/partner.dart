import 'package:flutter/foundation.dart';

@immutable
class Partner {
  final String slug;
  final String name;
  final String kind; // 'travel' | 'package'

  const Partner({
    required this.slug,
    required this.name,
    required this.kind,
  });
}
