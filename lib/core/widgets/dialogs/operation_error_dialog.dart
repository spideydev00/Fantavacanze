import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Dialog compatto per operazioni non consentite/errori applicativi.
class OperationErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onClose;

  const OperationErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Chiudi',
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      child: Container(
        width: Constants.getWidth(context) * 0.8,
        padding: const EdgeInsets.all(ThemeSizes.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/icons/other/error-icon.svg',
              width: 64,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium!
                  .copyWith(color: ColorPalette.error, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium!
                  .copyWith(color: context.textSecondaryColor),
            ),
            const SizedBox(height: ThemeSizes.lg),
            OutlinedButton(
              onPressed: () {
                if (onClose != null) {
                  onClose!();
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ColorPalette.error),
                foregroundColor: ColorPalette.error,
                padding: const EdgeInsets.symmetric(
                  vertical: ThemeSizes.sm,
                  horizontal: ThemeSizes.lg,
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
