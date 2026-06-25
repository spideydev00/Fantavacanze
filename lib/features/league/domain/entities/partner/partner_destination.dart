import 'package:flutter/foundation.dart';
import '../rule/rule.dart';
import 'partner_round.dart';

@immutable
class PartnerDestination {
  final String id;
  final String name;
  final String? description;
  final List<Rule> rules;
  final String? imageUrl;
  final PartnerRound? activeRound;
  final bool requiresPassword;

  const PartnerDestination({
    required this.id,
    required this.name,
    this.description,
    required this.rules,
    this.imageUrl,
    this.activeRound,
    this.requiresPassword = false,
  });
}
