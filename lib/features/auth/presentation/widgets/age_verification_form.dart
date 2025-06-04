import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/pages/app_terms.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/privacy_policy.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AgeVerificationForm extends StatefulWidget {
  final bool initialIsAdult;
  final bool initialIsTermsAccepted;
  final Function(bool, bool) onValueChanged;

  const AgeVerificationForm({
    super.key,
    this.initialIsAdult = false,
    this.initialIsTermsAccepted = false,
    required this.onValueChanged,
  });

  @override
  State<AgeVerificationForm> createState() => _AgeVerificationFormState();
}

class _AgeVerificationFormState extends State<AgeVerificationForm> {
  late bool _isAdult;
  late bool _isTermsAccepted;

  @override
  void initState() {
    super.initState();
    _isAdult = widget.initialIsAdult;
    _isTermsAccepted = widget.initialIsTermsAccepted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Age verification checkbox
        _buildCheckbox(
          value: _isAdult,
          onChanged: (value) {
            setState(() {
              _isAdult = value;
            });
            widget.onValueChanged(_isAdult, _isTermsAccepted);
          },
          label: Text(
            "Ho almeno 18 anni",
            style: TextStyle(
              color: ColorPalette.textPrimary(
                ThemeMode.dark,
              ),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: ThemeSizes.xs), // Reduced vertical spacing

        // Terms acceptance checkbox
        _buildCheckbox(
          value: _isTermsAccepted,
          onChanged: (value) {
            setState(() {
              _isTermsAccepted = value;
            });
            widget.onValueChanged(_isAdult, _isTermsAccepted);
          },
          label: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Accetto ",
                  style: TextStyle(
                    color: ColorPalette.textPrimary(ThemeMode.dark),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Termini ",
                  style: TextStyle(
                    color: ColorPalette.secondary(ThemeMode.dark),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        AppTermsPage.route,
                      );
                    },
                ),
                TextSpan(
                  text: "e ",
                  style: TextStyle(
                    color: ColorPalette.textPrimary(ThemeMode.dark),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Privacy  Policy",
                  style: TextStyle(
                    color: ColorPalette.secondary(ThemeMode.dark),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        PrivacyPolicyPage.route,
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required Function(bool) onChanged,
    required Widget label,
  }) {
    return Container(
      padding: const EdgeInsets.all(1),
      width: Constants.getWidth(context) * 0.65,
      decoration: BoxDecoration(
        color: ColorPalette.secondaryBgColor(ThemeMode.dark).withValues(
          alpha: 0.95,
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            activeColor: ColorPalette.success,
            checkColor: Colors.white,
            side: BorderSide(color: ColorPalette.textPrimary(ThemeMode.dark)),
            value: value,
            onChanged: (newValue) {
              onChanged(newValue ?? false);
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                onChanged(!value);
              },
              child: label,
            ),
          ),
        ],
      ),
    );
  }
}
