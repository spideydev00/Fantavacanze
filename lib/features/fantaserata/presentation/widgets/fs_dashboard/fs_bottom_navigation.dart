import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class FsBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FsBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.bgColor,
      padding: const EdgeInsets.only(
        left: ThemeSizes.sm,
        right: ThemeSizes.sm,
        bottom: ThemeSizes.xl,
      ),
      child: _buildFixedWidthNavbarRow(
        4,
        (index) {
          return _FsNavItem(
            icon: _getIconForIndex(index),
            label: _getLabelForIndex(index),
            isSelected: currentIndex == index,
            onTap: () => onTap(index),
          );
        },
      ),
    );
  }

  Widget _buildFixedWidthNavbarRow(
      int elements, Widget Function(int) generator) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(elements, (index) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
            child: generator(index),
          ),
        );
      }),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.flag_rounded;
      case 1:
        return Icons.leaderboard_rounded;
      case 2:
        return Icons.library_books_rounded;
      case 3:
        return Icons.construction_sharp;
      default:
        return Icons.flag_rounded;
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Obiettivi';
      case 1:
        return 'Classifica';
      case 2:
        return 'Eventi';
      case 3:
        return 'Lega';
      default:
        return 'Obiettivi';
    }
  }
}

class _FsNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FsNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedIndicator(context),
          const SizedBox(height: ThemeSizes.sm),
          Icon(
            icon,
            size: 24,
            color:
                isSelected ? context.primaryColor : context.textSecondaryColor,
          ),
          const SizedBox(height: ThemeSizes.sm),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? context.primaryColor
                  : context.textSecondaryColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIndicator(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: isSelected ? 1 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: isSelected ? 5 : 2,
        width: 16,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ColorPalette.fsGradients,
          ),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
          boxShadow: [
            BoxShadow(
              color: context.primaryColor.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
