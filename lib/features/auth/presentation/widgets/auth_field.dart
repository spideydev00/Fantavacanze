import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AuthField extends StatefulWidget {
  const AuthField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.icon,
      this.isPassword = false});

  final TextEditingController controller;
  final String hintText;
  final Widget? icon;
  final bool isPassword;

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
      cursorColor: ColorPalette.softBlack,
      style: context.textTheme.bodyLarge!.copyWith(
        color: ColorPalette.black,
      ),
      controller: widget.controller,
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
                  child: !showText
                      ? SvgPicture.asset(
                          "assets/images/icons/auth_field_icons/eye-show.svg")
                      : SvgPicture.asset(
                          "assets/images/icons/auth_field_icons/eye-hide.svg"),
                  onTap: () {
                    setState(() {
                      showText = !showText;
                    });
                  },
                ),
              )
            : null,
      ),
      obscureText: widget.isPassword && !showText,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Inserisci ${widget.hintText}';
        }

        return null;
      },
    );
  }
}
