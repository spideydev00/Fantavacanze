import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpField extends StatelessWidget {
  const OtpField({super.key, required this.onSaved});

  final FormFieldSetter<String?> onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (value) {
        if (value.length == 1) {
          FocusScope.of(context).nextFocus();
        }
      },
      onSaved: onSaved,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: false,
      ),
      textAlign: TextAlign.center,
      inputFormatters: [
        LengthLimitingTextInputFormatter(1),
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: const InputDecoration(
        filled: true,
        fillColor: ColorPalette.white,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: ColorPalette.primary,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: ColorPalette.darkerGrey,
            width: 0.8,
          ),
        ),
      ),
    );
  }
}
