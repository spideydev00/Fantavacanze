import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class FsInviteCodeCard extends StatelessWidget {
  final String inviteCode;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const FsInviteCodeCard({
    super.key,
    required this.inviteCode,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ColorPalette.fsGradients
              .map((color) => color.withValues(alpha: 0.1))
              .toList(),
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: context.primaryColor,
                size: 24,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Text(
                'Codice Invito FantaSerata',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSizes.lg),

          // Invite code display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: ThemeSizes.lg,
              horizontal: ThemeSizes.md,
            ),
            decoration: BoxDecoration(
              color: context.secondaryBgColor,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              inviteCode,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: context.textPrimaryColor,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: ThemeSizes.lg),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: context.primaryColor,
                      width: 2,
                    ),
                    foregroundColor: context.primaryColor,
                    padding:
                        const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                  ),
                  icon: Icon(Icons.copy_rounded),
                  label: Text(
                    'Copia',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: ThemeSizes.md),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: ColorPalette.fsGradients),
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding:
                          const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                    ),
                    icon: Icon(Icons.share_rounded),
                    label: Text(
                      'Condividi',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
