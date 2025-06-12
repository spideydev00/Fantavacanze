import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
// import 'package:fantavacanze_official/core/pages/app_terms.dart'
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Dialog that shows age verification and terms acceptance UI
/// This is used in the authentication flow when consents are required
class AgeVerificationDialog extends StatefulWidget {
  final Function(bool) onConfirm;
  final VoidCallback onCancel;
  final bool initialIsAdult;
  final String provider;

  const AgeVerificationDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.initialIsAdult = false,
    required this.provider,
  });

  static Future<bool?> show({
    required BuildContext context,
    required Function(bool) onConfirm,
    required VoidCallback onCancel,
    required String provider,
    bool initialIsAdult = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AgeVerificationDialog(
          onConfirm: onConfirm,
          onCancel: onCancel,
          initialIsAdult: initialIsAdult,
          provider: provider,
        );
      },
    );
  }

  @override
  State<AgeVerificationDialog> createState() => _AgeVerificationDialogState();
}

class _AgeVerificationDialogState extends State<AgeVerificationDialog>
    with SingleTickerProviderStateMixin {
  late bool _isAdult;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isAdult = widget.initialIsAdult;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get isFormValid => _isAdult;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: AlertDialog(
        backgroundColor: context.bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: Constants.getWidth(context) * 0.85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.symmetric(vertical: ThemeSizes.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorPalette.success.withValues(alpha: 0.9),
                      ColorPalette.success.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(ThemeSizes.borderRadiusLg),
                    topRight: Radius.circular(ThemeSizes.borderRadiusLg),
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: 40,
                        color: ColorPalette.white,
                      ),
                      const SizedBox(height: ThemeSizes.sm),
                      Text(
                        "Verifica",
                        style: context.textTheme.titleLarge?.copyWith(
                          color: ColorPalette.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(ThemeSizes.lg),
                child: Column(
                  children: [
                    Text(
                      "Per accedere a Fantavacanze con ${widget.provider}, devi confermare la tua età e accettare i nostri termini e condizioni.",
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: ThemeSizes.lg),

                    // Age verification checkbox
                    _buildVerificationItem(
                      title: "Dichiarazione di età",
                      isChecked: _isAdult,
                      onChanged: (value) {
                        setState(() {
                          _isAdult = value ?? false;
                        });
                      },
                      content: Text(
                        "Confermo di avere almeno 18 anni",
                        style: context.textTheme.bodyMedium,
                      ),
                    ),

                    // const SizedBox(height: ThemeSizes.md),

                    // // Terms acceptance checkbox
                    // _buildVerificationItem(
                    //   title: "Termini e condizioni",
                    //   isChecked: _isTermsAccepted,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _isTermsAccepted = value ?? false;
                    //     });
                    //   },
                    //   content: RichText(
                    //     text: TextSpan(
                    //       style: context.textTheme.bodyMedium,
                    //       children: [
                    //         TextSpan(
                    //           text: "Accetto ",
                    //         ),
                    //         TextSpan(
                    //           text: "Termini e Condizioni",
                    //           style: TextStyle(
                    //             color: context.secondaryColor,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //           recognizer: TapGestureRecognizer()
                    //             ..onTap = () {
                    //               Navigator.push(
                    //                 context,
                    //                 AppTermsPage.route,
                    //               );
                    //             },
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),

              // Buttons
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeSizes.lg,
                  vertical: ThemeSizes.md,
                ),
                decoration: BoxDecoration(
                  color: context.bgColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(ThemeSizes.borderRadiusLg),
                    bottomRight: Radius.circular(ThemeSizes.borderRadiusLg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onCancel();
                      },
                      style: context.outlinedButtonThemeData.style!,
                      child: const Text("Annulla"),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isFormValid
                            ? () {
                                Navigator.pop(context);
                                widget.onConfirm(_isAdult);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFormValid
                              ? context.primaryColor
                              : context.primaryColor.withValues(
                                  alpha:
                                      0.5), // Use primary color with reduced opacity when disabled
                          foregroundColor: ColorPalette.white,
                          disabledForegroundColor: ColorPalette.white.withValues(
                              alpha:
                                  0.7), // Slightly dim the text when disabled
                          disabledBackgroundColor: context.primaryColor
                              .withValues(
                                  alpha:
                                      0.5), // Override theme's disabled style
                        ),
                        child: const Text("Continua"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationItem({
    required String title,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
    required Widget content,
  }) {
    return InkWell(
      onTap: () {
        onChanged(!isChecked);
      },
      borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      child: Container(
        padding: const EdgeInsets.all(ThemeSizes.sm),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: isChecked,
                  activeColor: ColorPalette.success,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: onChanged,
                ),
                const SizedBox(width: 8),
                Expanded(child: content),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
