import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

class CustomLeading extends StatelessWidget {
  final VoidCallback onTap;

  const CustomLeading({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ThemeSizes.xxl,
        height: ThemeSizes.xxl,
        decoration: BoxDecoration(
          color: ColorPalette.secondaryBg,
          borderRadius: BorderRadius.circular(ThemeSizes.xl),
        ),
        child: Center(
          child: Icon(
            Icons.menu_rounded,
          ),
        ),
      ),
    );
  }
}
