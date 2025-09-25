import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';

class FsSuccessAnimation extends StatelessWidget {
  final double scale;

  const FsSuccessAnimation({
    super.key,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: ColorPalette.fsGradients),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ColorPalette.fsGradients.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.celebration_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
