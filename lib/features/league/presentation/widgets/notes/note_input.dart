import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class NoteInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final int maxLines;
  final void Function(String)? onSubmitted;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;

  const NoteInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText = 'Scrivi la tua nota qui...',
    this.maxLines = 3,
    this.onSubmitted,
    this.contentPadding = const EdgeInsets.all(ThemeSizes.md),
    this.borderRadius = ThemeSizes.borderRadiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: ColorPalette.success,
            width: 1.0,
          ),
        ),
        contentPadding: contentPadding,
      ),
      maxLines: maxLines,
      style: context.textTheme.bodyLarge,
      onSubmitted: onSubmitted,
    );
  }
}
