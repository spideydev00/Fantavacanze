import 'package:flutter/foundation.dart';
import 'partner.dart';
import 'partner_destination.dart';

@immutable
class PartnerCatalog {
  final Partner partner;
  final List<PartnerDestination> destinations;

  const PartnerCatalog({
    required this.partner,
    required this.destinations,
  });
}
