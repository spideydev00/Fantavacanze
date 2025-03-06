import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class PageRedirectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color iconColor;
  final double width;
  final double height;

  const PageRedirectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.color = ColorPalette.secondaryBg,
    this.iconColor = ColorPalette.primary,
    this.width = 160,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            onPressed;
          },
          splashColor: ColorPalette.primary.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(ThemeSizes.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ThemeSizes.lg),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.9),
                  color.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icona con effetto hover
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: context.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
