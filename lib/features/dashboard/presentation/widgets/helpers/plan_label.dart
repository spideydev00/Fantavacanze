import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class PlanLabel extends StatelessWidget {
  final String plan;

  const PlanLabel({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    bool isPremium = plan.toLowerCase() == 'premium';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorPalette.primary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.star : Icons.lock_outline,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isPremium ? 'Premium' : 'Gratis',
            style: context.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
