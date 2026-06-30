import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final String darkSvgIcon;
  final String lightSvgIcon;
  final IconData? icon;
  final Widget screen;
  final String subsection;
  final bool isAdminOnly;
  final bool requiresPartnerRound;

  /// Mostrato solo per leghe partner di tipo package (partner senza round).
  final bool requiresPackage;

  /// Mostrato solo se l'utente NON ha ancora leghe del partner "invibe".
  final bool requiresNoInvibeLeague;

  /// Mostrato solo se l'utente ha almeno una lega del partner "invibe".
  final bool requiresInvibeLeague;

  /// Se false l'item compare solo nel side menu, non nella bottom navbar.
  final bool showInNavbar;

  const NavigationItem({
    required this.title,
    required this.lightSvgIcon,
    required this.darkSvgIcon,
    required this.screen,
    required this.subsection,
    this.icon,
    this.isAdminOnly = false,
    this.requiresPartnerRound = false,
    this.requiresPackage = false,
    this.requiresNoInvibeLeague = false,
    this.requiresInvibeLeague = false,
    this.showInNavbar = true,
  });
}
