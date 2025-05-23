import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final double height;
  final void Function(String)? onChanged;
  final VoidCallback? onClearPressed;
  final EdgeInsetsGeometry margin;
  final bool showClearButton;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Cerca...',
    this.prefixIcon = Icons.search,
    this.height = 48.0,
    this.onChanged,
    this.onClearPressed,
    this.margin = const EdgeInsets.only(bottom: ThemeSizes.md),
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;

    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: context.textSecondaryColor),
          prefixIcon: Icon(prefixIcon, size: 20),
          suffixIcon: (showClearButton && hasText)
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    controller.clear();
                    if (onClearPressed != null) {
                      onClearPressed!();
                    }
                    if (onChanged != null) {
                      onChanged!('');
                    }
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: TextStyle(color: context.textPrimaryColor),
      ),
    );
  }
}
