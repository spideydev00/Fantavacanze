import 'package:flutter/material.dart';

extension CustomContext on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  ElevatedButtonThemeData get elevatedButtonThemeData =>
      Theme.of(this).elevatedButtonTheme;
  InputDecorationTheme get inputDecorationTheme =>
      Theme.of(this).inputDecorationTheme;
}
