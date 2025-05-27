import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/main.dart';

/// Mostra una SnackBar utilizzando il messengerKey globale.
/// - [message]: testo da visualizzare
/// - [color]: colore di sfondo (default il primario)
/// - [duration]: durata della SnackBar
void showSnackBar(
  String content, {
  Color? color,
  Duration duration = const Duration(seconds: 3),
}) {
  messengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          content,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color ?? ColorPalette.error,
        duration: duration,
      ),
    );
}
