// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class NavigationItem {
  final String? title;
  final String svgIcon;
  final Widget screen;

  NavigationItem({
    this.title,
    required this.svgIcon,
    required this.screen,
  });
}
