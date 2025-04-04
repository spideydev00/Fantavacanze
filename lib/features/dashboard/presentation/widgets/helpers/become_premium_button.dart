import 'dart:ui';

import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BecomePremiumButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BecomePremiumButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeSizes.xs),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            ThemeSizes.borderRadiusXlg,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFf9af48).withValues(alpha: 0.5),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ElevatedButton.icon(
              label: Text(
                "Passa a Premium",
                style: context.textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              icon: SvgPicture.asset(
                "assets/images/icons/homepage_icons/premium-icon.svg",
                width: 28,
              ),
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf9af48).withValues(alpha: 0.8),
                fixedSize: Size(
                  MediaQuery.of(context).size.width * 0.6,
                  48, // Add a fixed height for better consistency
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusXlg),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                elevation: 0, // Remove default elevation
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.lg,
                  vertical: ThemeSizes.sm,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
