import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String content,
    {Color color = ColorPalette.error}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          content,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
}
