import 'package:flutter/material.dart';

class NavigationItem {
  final String? title, subsection;
  final String lightSvgIcon;
  final String darkSvgIcon;
  final Widget screen;

  NavigationItem({
    this.title,
    this.subsection,
    required this.lightSvgIcon,
    required this.darkSvgIcon,
    required this.screen,
  });
}
