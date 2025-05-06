import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class LeaveLeagueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final AnimationController animationController;
  final Animation<double> scaleAnimation;

  const LeaveLeagueButton({
    super.key,
    required this.onPressed,
    required this.animationController,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => animationController.forward(),
          onTapUp: (_) => animationController.reverse(),
          onTapCancel: () => animationController.reverse(),
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.error.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  splashColor: Colors.white.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeSizes.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.exit_to_app,
                          color: Colors.white,
                        ),
                        const SizedBox(width: ThemeSizes.sm),
                        const Text(
                          'Lascia la Lega',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
