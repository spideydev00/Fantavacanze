import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProcessingState extends Equatable {
  final String message;
  final double? progress;

  const ProcessingState(this.message, {this.progress});

  @override
  List<Object?> get props => [message, progress];
}

class ProcessingDialog extends StatelessWidget {
  final ValueListenable<ProcessingState> state;
  final IconData leadingIcon;
  final VoidCallback? onCancel;

  const ProcessingDialog({
    super.key,
    required this.state,
    required this.leadingIcon,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: context.bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
        contentPadding: const EdgeInsets.all(ThemeSizes.lg),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primaryColor.withValues(alpha: .1),
                ),
                child: Icon(
                  leadingIcon,
                  color: context.primaryColor,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            ValueListenableBuilder<ProcessingState>(
              valueListenable: state,
              builder: (_, value, __) => Column(
                children: [
                  Text(
                    value.message,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  if (value.progress != null) ...[
                    LinearProgressIndicator(
                      value: value.progress,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(
                        ThemeSizes.borderRadiusSm,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.primaryColor,
                      ),
                      backgroundColor:
                          context.borderColor.withValues(alpha: .2),
                    ),
                    const SizedBox(height: ThemeSizes.xs),
                    Text(
                      '${(value.progress! * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ] else
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: onCancel == null
            ? null
            : [
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    'Annulla',
                    style: TextStyle(
                      color: ColorPalette.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
