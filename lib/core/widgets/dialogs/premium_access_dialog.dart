import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/widgets/buttons/gradient_option_button.dart';
import 'package:flutter/services.dart';

class PremiumAccessDialog extends StatefulWidget {
  /// Set to true to show only premium option without ads option
  final bool premiumOnly;

  /// Optional custom title for the dialog
  final String? title;

  /// Optional custom description text
  final String? description;

  /// Callback when the ads button is tapped
  final VoidCallback? onAdsBtnTapped;

  /// Callback when the premium button is tapped
  final VoidCallback? onPremiumBtnTapped;

  const PremiumAccessDialog({
    super.key,
    this.premiumOnly = false,
    this.title,
    this.description,
    this.onAdsBtnTapped,
    this.onPremiumBtnTapped,
  });

  @override
  State<PremiumAccessDialog> createState() => _PremiumAccessDialogState();
}

class _PremiumAccessDialogState extends State<PremiumAccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusXlg),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.xl),
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusXlg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dialog title with sparkle emoji
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.title ?? 'Ooops..',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSizes.md),

          // Dialog content
          Text(
            widget.description ?? 'Sblocca ora:',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: ThemeSizes.xl),

          // Option buttons - either single premium or dual options
          if (widget.premiumOnly)
            // Premium-only mode: Center the premium button with larger width
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: GradientOptionButton(
                  isSelected: true,
                  label: 'Premium',
                  description: 'Sblocca tutto e rimuovi le pubblicità',
                  icon: Icons.star,
                  primaryColor: ColorPalette.premiumGradient[0],
                  secondaryColor: ColorPalette.premiumGradient[2],
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    if (widget.onPremiumBtnTapped != null) {
                      widget.onPremiumBtnTapped!();
                    }
                  },
                ),
              ),
            )
          else
            // Dual option mode: Show both premium and ads options
            Row(
              children: [
                // Option 1: Premium subscription with gradient
                Expanded(
                  child: GradientOptionButton(
                    isSelected: true,
                    label: 'Premium',
                    description: 'Sblocca tutto e rimuovi le pubblicità',
                    icon: Icons.star,
                    primaryColor: ColorPalette.premiumGradient[0],
                    secondaryColor: ColorPalette.premiumGradient[2],
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      if (widget.onPremiumBtnTapped != null) {
                        widget.onPremiumBtnTapped!();
                      }
                    },
                  ),
                ),

                const SizedBox(width: ThemeSizes.md),

                // Option 2: Watch ads with gradient
                Expanded(
                  child: GradientOptionButton(
                    isSelected: true,
                    label: 'Ads',
                    description: 'Guarda 1 ad per ottenere l\'accesso',
                    icon: Icons.ondemand_video,
                    primaryColor: ColorPalette.adsGradient[0],
                    secondaryColor: ColorPalette.adsGradient[2],
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      if (widget.onAdsBtnTapped != null) {
                        widget.onAdsBtnTapped!();
                      }
                    },
                  ),
                ),
              ],
            ),

          const SizedBox(height: ThemeSizes.lg),
        ],
      ),
    );
  }
}
