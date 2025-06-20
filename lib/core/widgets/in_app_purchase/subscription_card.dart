import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

class GradientSubscriptionCard extends StatelessWidget {
  final ProductDetails plan;
  final bool isSelected;
  final bool isMonthly;
  final VoidCallback onTap;

  const GradientSubscriptionCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.isMonthly,
    required this.onTap,
  });

  String _getLocalizedTitle(ProductDetails product) {
    if (product.id.contains('monthly')) {
      return 'Piano Mensile';
    } else if (product.id.contains('annual')) {
      return 'Piano Annuale';
    }
    return product.title.split('(').first;
  }

  String _getDurationTitle(String idCode) {
    if (idCode.contains('monthly')) {
      return "al mese";
    }
    return "all'anno";
  }

  @override
  Widget build(BuildContext context) {
    // Define gradient colors based on plan type and selection status
    final List<Color> gradientColors = isMonthly
        ? [
            const Color(0xFF8A2387),
            const Color(0xFFE94057),
            const Color(0xFFF27121),
          ]
        : [
            const Color(0xFF1A2980),
            const Color(0xFF26D0CE),
          ];
    
    // Calculate discount percentage for annual plan (if applicable)
    final bool hasDiscount = !isMonthly;
    final String discountText = hasDiscount ? "Risparmia 25%" : "";
    
    // Plan-specific icon
    final IconData planIcon = isMonthly
        ? Icons.calendar_month_rounded
        : Icons.calendar_today_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Stack(
          children: [
            // Main card with gradient
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? ColorPalette.premiumUser
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? gradientColors.first.withValues(alpha: 0.3)
                        : gradientColors.first.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? gradientColors
                        : gradientColors.map(
                            (color) => color.withValues(alpha: 0.1),
                          ).toList()
                  ),
                ),
                child: Row(
                  children: [
                    // Left side - Plan icon and info
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          // Radio button or plan icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : gradientColors.first.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              planIcon,
                              size: 24,
                              color: isSelected
                                  ? Colors.white
                                  : gradientColors.first,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Plan name and description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getLocalizedTitle(plan),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : context.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  plan.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : context.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Right side - Price info
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            plan.price,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : context.textPrimaryColor,
                            ),
                          ),
                          Text(
                            _getDurationTitle(plan.id),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : context.textSecondaryColor,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : ColorPalette.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                discountText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : ColorPalette.success,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Selection indicator (checkmark)
            if (isSelected)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 14,
                    color: ColorPalette.premiumUser,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
