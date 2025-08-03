import 'package:flutter/foundation.dart';

/// Utility class for formatting numbers in the app
class NumberFormatter {
  /// Formats a double as a string without decimal places
  /// unless it has a .5 value
  static String formatPoints(double value) {
    // If the fractional part is exactly 0.5, show one decimal place
    if ((value * 10) % 10 == 5) {
      return value.toStringAsFixed(1);
    }
    // Otherwise show as integer
    return value.toStringAsFixed(0);
  }

  /// For debugging - prints formatted value
  static void debugFormatPoints(double value) {
    if (kDebugMode) {
      print('Original: $value, Formatted: ${formatPoints(value)}');
    }
  }
}
