import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.onInputChanged,
    required this.onTrashIconTap,
    required this.onInputValidated,
  });

  final TextEditingController controller;
  final Function(PhoneNumber number) onInputChanged;
  final Function(bool isValidNumber) onInputValidated;
  final VoidCallback onTrashIconTap;

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
      textStyle: context.textTheme.bodyLarge!.copyWith(
        color: ColorPalette.black,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: ColorPalette.black,
      //Per salvare il valore booleano di validazione
      onInputValidated: onInputValidated,
      //Per salvare il numero di telefono in una variabile
      onInputChanged: onInputChanged,
      //Commenta se si usa un solo paese e inserisci padding
      selectorConfig: const SelectorConfig(
        // selectorType: PhoneInputSelectorType.DROPDOWN,
        leadingPadding: 12,
        trailingSpace: true,
        useBottomSheetSafeArea: true,
        setSelectorButtonAsPrefixIcon: true,
      ),
      ignoreBlank: false,
      formatInput: true,
      selectorTextStyle: context.textTheme.bodyLarge!.copyWith(
        color: ColorPalette.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      textFieldController: controller,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      inputDecoration: InputDecoration(
        hintText: "Numero di telefono...",
        hintStyle: context.textTheme.bodyLarge!.copyWith(
          color: ColorPalette.black.withOpacity(0.5),
          fontSize: 16,
        ),
        // fillColor: ColorPalette.white,
        border:
            AppTheme.border(Colors.transparent, 0, ThemeSizes.borderRadiusLg),
        enabledBorder:
            AppTheme.border(Colors.transparent, 0, ThemeSizes.borderRadiusLg),
        focusedBorder:
            AppTheme.border(Colors.transparent, 0, ThemeSizes.borderRadiusLg),
        //icona di chiusura
        suffixIcon: GestureDetector(
          onTap: onTrashIconTap,
          child: const Icon(
            Icons.delete_rounded,
            size: 28,
            color: ColorPalette.primary,
          ),
        ),
      ),
      //Scalabile. Per ora Italia e Svizzera.
      countries: const ['IT'],

      /* validator: (value) {
        if (value!.isEmpty || value.length < 10) {
          return "Il numero fornito non è valido!";
        }

        return null;
      }, */
    );
  }
}
