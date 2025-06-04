import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';

class TypeSelector extends StatelessWidget {
  final RuleType selectedType;
  final Function(RuleType) onTypeChanged;

  const TypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: Row(
        children: [
          _buildTypeOption(
            context,
            RuleType.bonus,
            'Bonus',
            Icons.trending_up,
            ColorPalette.success,
          ),
          _buildTypeOption(
            context,
            RuleType.malus,
            'Malus',
            Icons.trending_down,
            ColorPalette.error,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context,
    RuleType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: ThemeSizes.lg,
            horizontal: ThemeSizes.md,
          ),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : context.textSecondaryColor,
                size: 24,
              ),
              const SizedBox(height: ThemeSizes.sm),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
