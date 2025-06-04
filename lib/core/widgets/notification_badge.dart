import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final double? top;
  final double? right;
  final double size;
  final Color badgeColor;
  final Color textColor;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.top = -5,
    this.right = -5,
    this.size = 16,
    this.badgeColor = ColorPalette.error,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: top,
            right: right,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: size,
                minHeight: size,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: size / 2,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
