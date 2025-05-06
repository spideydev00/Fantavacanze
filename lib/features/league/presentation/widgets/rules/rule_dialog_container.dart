import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';

/// A container component for rule dialogs
///
/// This component provides a consistent appearance for rule dialogs
/// with proper styling, padding, and shadow.
class RuleDialogContainer extends StatelessWidget {
  /// The child content to display in the container
  final Widget child;

  /// Optional padding for the container content
  final EdgeInsets? padding;

  /// Optional inset padding for the dialog
  final EdgeInsets? insetPadding;

  /// Optional border radius for the container
  final double borderRadius;

  const RuleDialogContainer({
    super.key,
    required this.child,
    this.padding,
    this.insetPadding,
    this.borderRadius = ThemeSizes.borderRadiusLg,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding:
          insetPadding ?? const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
      child: Container(
        decoration: BoxDecoration(
          color: context.bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(ThemeSizes.lg),
        child: child,
      ),
    );
  }
}
