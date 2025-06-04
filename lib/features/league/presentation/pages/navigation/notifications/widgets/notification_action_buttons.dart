import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class NotificationActionButtons extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String approveText;
  final String rejectText;
  final bool compact;

  const NotificationActionButtons({
    super.key,
    required this.onApprove,
    required this.onReject,
    this.approveText = 'Approva',
    this.rejectText = 'Rifiuta',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reject button - icon only
          IconButton(
            onPressed: onReject,
            icon: const Icon(Icons.close),
            color: ColorPalette.warning,
            tooltip: rejectText,
            style: IconButton.styleFrom(
              backgroundColor: ColorPalette.warning.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(width: 8),
          // Approve button - icon only
          IconButton(
            onPressed: onApprove,
            icon: const Icon(Icons.check),
            color: ColorPalette.success,
            tooltip: approveText,
            style: IconButton.styleFrom(
              backgroundColor: ColorPalette.success.withValues(alpha: 0.1),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Reject button - outlined button
        Expanded(
          child: OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorPalette.warning,
              side: const BorderSide(color: ColorPalette.warning),
            ),
            child: Text(rejectText),
          ),
        ),
        const SizedBox(width: ThemeSizes.sm),
        // Approve button
        Expanded(
          child: ElevatedButton(
            onPressed: onApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.success,
              foregroundColor: Colors.white,
            ),
            child: Text(approveText),
          ),
        ),
      ],
    );
  }
}
