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
    this.showInNavbar = true,
  });
}
