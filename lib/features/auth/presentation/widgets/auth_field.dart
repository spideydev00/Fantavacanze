import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
    this.autovalidateMode,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final Widget? icon;
  final bool isPassword;

  // Nuovi parametri
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final AutovalidateMode? autovalidateMode;
  final void Function(String)? onChanged;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool showText;

  @override
  void initState() {
    super.initState();
    showText = false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      cursorColor: ColorPalette.softBlack,
      style: context.textTheme.bodyLarge!.copyWith(
        color: ColorPalette.black,
      ),
      obscureText: widget.isPassword && !showText,
      keyboardType: widget.keyboardType,
      autovalidateMode: widget.autovalidateMode,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        fillColor: Colors.white,
        hintText: widget.hintText,
        prefixIcon: widget.icon,
        suffixIcon: widget.isPassword
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: ThemeSizes.sm,
                  horizontal: ThemeSizes.md,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => showText = !showText),
                  child: SvgPicture.asset(
                    showText
                        ? "assets/images/icons/auth_field_icons/eye-hide.svg"
                        : "assets/images/icons/auth_field_icons/eye-show.svg",
                  ),
                ),
              )
            : null,
      ),
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Inserisci ${widget.hintText.toLowerCase()}';
            }
            return null;
          },
    );
  }
}
