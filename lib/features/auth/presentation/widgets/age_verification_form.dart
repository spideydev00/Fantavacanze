import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/pages/app_terms.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
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
        // Age verification container
        Container(
          padding: const EdgeInsets.symmetric(
              vertical: 4, horizontal: ThemeSizes.xs),
          width: Constants.getWidth(context) * 0.65,
          decoration: BoxDecoration(
            color: ColorPalette.secondary(ThemeMode.dark),
            borderRadius: BorderRadius.circular(ThemeSizes.sm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                activeColor: ColorPalette.primary(ThemeMode.light),
                checkColor: Colors.white,
                side: BorderSide(color: ColorPalette.primary(ThemeMode.light)),
                value: _isAdult,
                onChanged: (value) {
                  setState(() {
                    _isAdult = value ?? false;
                  });
                  widget.onValueChanged(_isAdult, _isTermsAccepted);
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAdult = !_isAdult;
                    });
                    widget.onValueChanged(_isAdult, _isTermsAccepted);
                  },
                  child: Text(
                    "Ho almeno 18 anni",
                    style: TextStyle(
                      color: ColorPalette.textPrimary(
                        ThemeMode.light,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: ThemeSizes.xs), // Reduced vertical spacing

        // Terms acceptance container
        Container(
          padding: const EdgeInsets.symmetric(
              vertical: 4, horizontal: ThemeSizes.xs),
          width: Constants.getWidth(context) * 0.65,
          decoration: BoxDecoration(
            color: ColorPalette.secondary(ThemeMode.dark),
            borderRadius: BorderRadius.circular(ThemeSizes.sm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                activeColor: ColorPalette.primary(ThemeMode.light),
                checkColor: Colors.white,
                side: BorderSide(color: ColorPalette.primary(ThemeMode.light)),
                value: _isTermsAccepted,
                onChanged: (value) {
                  setState(() {
                    _isTermsAccepted = value ?? false;
                  });
                  widget.onValueChanged(_isAdult, _isTermsAccepted);
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isTermsAccepted = !_isTermsAccepted;
                    });
                    widget.onValueChanged(_isAdult, _isTermsAccepted);
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Accetto i ",
                          style: TextStyle(
                            color: ColorPalette.textPrimary(ThemeMode.light),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "Termini e Condizioni",
                          style: TextStyle(
                            color: ColorPalette.primary(ThemeMode.light),
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
