import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_premium_paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/buttons/gradient_option_button.dart';

class PremiumAccessDialog extends StatefulWidget {
  final bool premiumOnly;
  final String? title;
  final String? description;
  final Future<bool> Function()? onAdsBtnTapped;

  const PremiumAccessDialog({
    super.key,
    this.premiumOnly = false,
    this.title,
    this.description,
    this.onAdsBtnTapped,
  });

  @override
  State<PremiumAccessDialog> createState() => _PremiumAccessDialogState();
}

class _PremiumAccessDialogState extends State<PremiumAccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleAdsTap() async {
    if (_isLoading) return;
    HapticFeedback.mediumImpact();

    // Se non c'è callback, chiudo e concedo comunque
    if (widget.onAdsBtnTapped == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _isLoading = true);

    bool granted;

    try {
      granted = await widget.onAdsBtnTapped!();
    } catch (e) {
      debugPrint('Error showing ad: $e');
      granted = true;
    }

    if (mounted) Navigator.of(context).pop(granted);
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Contenuto disabilitato in loading, con opacità ridotta
          IgnorePointer(
            ignoring: _isLoading,
            child: Opacity(
              opacity: _isLoading ? 0.5 : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titolo
                  Text(
                    widget.title ?? 'Ooops...',
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    semanticsLabel: widget.title ?? 'Sblocca ora',
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  // Descrizione
                  Text(
                    widget.description ?? 'Sblocca ora:',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium,
                    semanticsLabel: widget.description ?? 'Scegli opzione',
                  ),
                  const SizedBox(height: ThemeSizes.xl),
                  // Pulsanti
                  if (widget.premiumOnly)
                    _buildPremiumOnlyButton(context)
                  else
                    _buildDualOptionButtons(context),
                  const SizedBox(height: ThemeSizes.lg),
                ],
              ),
            ),
          ),
          // Loader centrale
          if (_isLoading)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.success),
            ),
        ],
      ),
    );
  }

  Widget _buildPremiumOnlyButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: GradientOptionButton(
          isSelected: true,
          label: 'Premium',
          description: 'Sblocca tutto e rimuovi le pubblicità',
          icon: Icons.star,
          primaryColor: ColorPalette.premiumGradient[0],
          secondaryColor: ColorPalette.premiumGradient[2],
          onTap: () async {
            if (_isLoading) return;
            HapticFeedback.mediumImpact();

            // chiudi il dialogo ma passa true se l'acquisto è andato a buon fine
            final isPremium = await showPremiumPaywall(context);

            if (context.mounted) {
              Navigator.of(context).pop(isPremium);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDualOptionButtons(BuildContext context) {
    return Row(
      children: [
        // Premium
        Expanded(
          child: GradientOptionButton(
            isSelected: true,
            label: 'Premium',
            description: 'Sblocca tutto e rimuovi le pubblicità',
            icon: Icons.star,
            primaryColor: ColorPalette.premiumGradient[0],
            secondaryColor: ColorPalette.premiumGradient[2],
            onTap: () async {
              if (_isLoading) return;
              HapticFeedback.mediumImpact();

              // Chiudi il dialogo e attendi l'acquisto
              final isPremium = await showPremiumPaywall(context);

              if (context.mounted) {
                Navigator.of(context).pop(isPremium);
              }
            },
          ),
        ),
        const SizedBox(width: ThemeSizes.md),
        // Ads
        Expanded(
          child: GradientOptionButton(
            isSelected: true,
            label: 'Ads',
            description: 'Guarda 1 ad per ottenere l\'accesso',
            icon: Icons.ondemand_video,
            primaryColor: ColorPalette.adsGradient[0],
            secondaryColor: ColorPalette.adsGradient[2],
            onTap: _handleAdsTap,
          ),
        ),
      ],
    );
  }
}
