import 'package:flutter/foundation.dart';
import '../league/league.dart';

enum PartnerSearchStatus { found, notFound, wrongPassword }

@immutable
class PartnerSearchResult {
  final PartnerSearchStatus status;
  final League? league;
  final String? destinationName;
  final String? roundName;

  const PartnerSearchResult({
    required this.status,
    this.league,
    this.destinationName,
    this.roundName,
  });
}
