import 'package:flutter/material.dart';

class ColorPalette {
  // Method to get dynamic colors based on theme mode
  static Color getColor(
      Color darkModeColor, Color lightModeColor, ThemeMode themeMode) {
    return themeMode == ThemeMode.dark ? darkModeColor : lightModeColor;
  }

  // App theme colors
  static Color primary(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 196, 67, 67),
      const Color.fromARGB(255, 196, 67, 67),
      themeMode);

  static Color secondary(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 242, 166, 166),
      const Color.fromARGB(255, 222, 146, 146),
      themeMode);

  static Color ternary(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 255, 219, 219),
      const Color.fromARGB(255, 235, 199, 199),
      themeMode);

  static Color accent(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 157, 49, 49),
      const Color.fromARGB(255, 196, 67, 67),
      themeMode);

  // Text colors
  static Color textPrimary(ThemeMode themeMode) => getColor(
      const Color(0xFFF6F6F6),
      const Color.fromARGB(255, 20, 20, 20),
      themeMode);

  static Color textSecondary(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 214, 214, 214),
      const Color.fromARGB(255, 47, 47, 47),
      themeMode);

  // Background colors
  static Color bgColor(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 11, 11, 13),
      const Color.fromARGB(255, 236, 229, 229),
      themeMode);

  static Color secondaryBgColor(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 24, 26, 33),
      const Color.fromARGB(255, 243, 243, 243),
      themeMode);

  //social buttons colors - these don't change with theme
  static const List<Color> googleGradientsBg = [
    Color.fromARGB(255, 187, 57, 57),
    Color.fromARGB(255, 226, 225, 119),
    Color.fromARGB(255, 83, 140, 183),
  ];

  static const Color discord = Color.fromARGB(255, 103, 125, 205);
  static const Color apple = Colors.black;
  static const Color facebook = Color.fromARGB(255, 32, 71, 134);

  // Button colors
  static Color buttonPrimary(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 194, 34, 34),
      const Color.fromARGB(255, 214, 54, 54),
      themeMode);

  static Color buttonSecondary(ThemeMode themeMode) =>
      getColor(const Color(0xFF6C757D), const Color(0xFF8C959D), themeMode);

  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border colors
  static Color borderColor(ThemeMode themeMode) =>
      getColor(const Color(0xFFD9D9D9), const Color(0xFFB9B9B9), themeMode);

  static const Color focusedBorder = Color.fromARGB(255, 196, 67, 67);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color.fromARGB(255, 135, 126, 209);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color softBlack = Color.fromARGB(255, 59, 59, 59);
  static const Color darkerGrey = Color.fromARGB(255, 91, 91, 91);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);

  // Extra
  static const Color darkerGreen = Color.fromARGB(255, 28, 60, 49);
  static const Color premiumUser = Color.fromARGB(255, 197, 127, 6);
}
