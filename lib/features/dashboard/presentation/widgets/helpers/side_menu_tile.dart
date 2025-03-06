import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class SideMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SideMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeSizes.md),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : ColorPalette.lightGrey,
          ),
          title: Text(
            title,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
