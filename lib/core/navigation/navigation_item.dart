import 'package:flutter/material.dart';

class NavigationItem {
  final String? title, subsection;
  final String svgIcon;
  final Widget screen;

  NavigationItem({
    this.title,
    this.subsection,
    required this.svgIcon,
    required this.screen,
  });
}
