import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final String darkSvgIcon;
  final String lightSvgIcon;
  final Widget screen;
  final String subsection;
  final bool isAdminOnly;

  const NavigationItem({
    required this.title,
    required this.lightSvgIcon,
    required this.darkSvgIcon,
    required this.screen,
    required this.subsection,
    this.isAdminOnly = false,
  });
}
