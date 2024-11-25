import 'package:flutter/material.dart';

class ColorPalette {
  // App theme colors
  static const Color primary = Color.fromARGB(255, 196, 67, 67);
  static const Color secondary = Color.fromARGB(255, 242, 166, 166);
  static const Color accent = Color.fromARGB(255, 157, 49, 49);

  // Text colors
  static const Color textPrimary = Color(0xFFF6F6F6);
  static const Color textSecondary = Color.fromARGB(255, 20, 20, 20);

  // Background colors
  static const Color lightBg = Color(0xFFF6F6F6);
  static const Color darkBg = Color.fromARGB(255, 20, 20, 20);

  static const List<Color> googleGradientsBg = [
    Color.fromARGB(255, 187, 57, 57),
    Color.fromARGB(255, 226, 225, 119),
    Color.fromARGB(255, 83, 140, 183),
  ];

  // Background Container colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = const Color.fromARGB(255, 20, 20, 20);
  static Color blueContainer = const Color.fromARGB(255, 46, 74, 144);
  static Color greenContainer = const Color.fromARGB(255, 64, 138, 115);

  // Button colors
  static const Color buttonPrimary = Color.fromARGB(255, 196, 67, 67);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border colors
  static const Color borderColor = Color(0xFFD9D9D9);
  static const Color focusedBorder = Color.fromARGB(255, 196, 67, 67);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color.fromARGB(255, 91, 91, 91);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
}
