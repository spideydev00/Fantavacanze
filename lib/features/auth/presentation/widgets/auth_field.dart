import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  const AuthField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.isPassword = false});

  final TextEditingController controller;
  final String hintText;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: ColorPalette.softBlack,
      style: context.textTheme.bodyLarge!.copyWith(
        color: ColorPalette.black,
      ),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      obscureText: isPassword,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Inserisci $hintText';
        }

        return null;
      },
    );
  }
}
