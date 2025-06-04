import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/main.dart'; // Import main.dart to access messengerKey

void showSnackBar(
  String message, {
  Color color = ColorPalette.error,
  Duration duration = const Duration(seconds: 2),
  SnackBarAction? action,
}) {
  if (messengerKey.currentState != null) {
    // Hide any existing snackbars
    messengerKey.currentState!.hideCurrentSnackBar();

    messengerKey.currentState!.showSnackBar(
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
  } else {
    debugPrint(
        '⚠️ ScaffoldMessengerKey not initialized for snackbar: $message');
  }
}
