import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

void showSpecificSnackBar(
  BuildContext context,
  String message, {
  Color color = ColorPalette.error,
  Duration duration = const Duration(seconds: 2),
  SnackBarAction? action,
}) {
  // Hide any existing snackbars
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
