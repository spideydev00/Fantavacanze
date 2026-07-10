import 'package:flutter/foundation.dart';

@immutable
class PartnerRound {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final bool requiresPassword;

  const PartnerRound({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    this.requiresPassword = false,
  });
}
