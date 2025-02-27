import 'package:fantavacanze_official/core/common/widgets/loader.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/custom_dialog_box.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String socialName;
  final bool isGradient;
  final List<Color>? bgGradient;
  final Color? bgColor;
  final Color foregroundColor;
  final Color loaderColor;
  final double width;
  final bool isIconOnly;
  final AuthState loadingState;

  const SocialButton({
    super.key,
    required this.onPressed,
    required this.loaderColor,
    required this.loadingState,
    required this.socialName,
    required this.isGradient,
    required this.width,
    required this.isIconOnly,
    this.bgGradient,
    this.bgColor,
    this.foregroundColor = ColorPalette.white,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          showDialog(
            context: context,
            builder: (context) => CustomDialogBox(
              title: "$socialName Error!",
              description: state.message,
              type: DialogType.error,
              isMultiButton: false,
            ),
          );
        }
        if (state is AuthSuccess) {
          Navigator.of(context)
              .pushAndRemoveUntil(OnBoardingScreen.route, (route) => false);
        }
      },
      builder: (context, state) {
        if (state.runtimeType == loadingState.runtimeType) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: ThemeSizes.lg),
              child: Loader(
                color: loaderColor,
              ),
            ),
          );
        }
        return Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(ThemeSizes.buttonRadius),
            ),
            color: !isGradient ? bgColor : null,
            gradient: isGradient
                ? LinearGradient(
                    colors: bgGradient!,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
          ),
          child: isIconOnly
              //Mostra solo icona
              ? ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: ColorPalette.textPrimary,
                    elevation: 0,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/icons/auth_icons/${socialName.toLowerCase()}.svg',
                    width: Constants.getWidth(context) * 0.12,
                  ),
                )
              //Mostra icona + testo
              : ElevatedButton.icon(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: ColorPalette.textPrimary,
                    elevation: 0,
                  ),
                  label: Text(
                    'Accedi con $socialName',
                    style: context.textTheme.bodyLarge!.copyWith(
                      fontSize: ThemeSizes.fontSizeMd,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor,
                    ),
                  ),
                  icon: SvgPicture.asset(
                    'assets/images/icons/auth_icons/${socialName.toLowerCase()}.svg',
                    width: Constants.getWidth(context) * 0.1,
                    colorFilter: ColorFilter.mode(
                      foregroundColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
