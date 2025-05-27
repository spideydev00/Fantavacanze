import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/buttons/modern_icon_button.dart';
import 'package:flutter/material.dart';

class AdminActionCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final IconData iconData;
  final VoidCallback onTap;
  final double height;
  final double buttonPadding;
  final double buttonPosition;

  const AdminActionCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.iconData = Icons.add,
    required this.onTap,
    this.height = 160.0,
    this.buttonPadding = 18.0,
    this.buttonPosition = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Container with image and text (positioned to allow button overlap)
        Padding(
          padding:
              const EdgeInsets.only(left: 30.0), // Space for button overlap
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // Gradient overlay for better readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(ThemeSizes.lg),
                      child: Row(
                        children: [
                          const SizedBox(
                              width: 24), // Space for the overlapping button
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: ThemeSizes.xs),
                                Text(
                                  title,
                                  style:
                                      context.textTheme.headlineSmall?.copyWith(
                                    color: ColorPalette.textPrimary(
                                        ThemeMode.dark),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: ThemeSizes.xs),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Overlapping modern icon button
        Positioned(
          top: buttonPosition, // Center the button vertically
          left: 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ModernIconButton(
              icon: iconData,
              iconSize: 30,
              padding: EdgeInsets.all(buttonPadding),
              iconColor: context.textPrimaryColor,
              backgroundColor: context.secondaryBgColor,
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }
}
