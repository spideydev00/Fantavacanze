import 'dart:io';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/signup.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/standard_login.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/age_verification_dialog.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/promo_text.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/rich_text.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/social_button.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/auth_dialog_box.dart';
import 'package:fantavacanze_official/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialLoginPage extends StatefulWidget {
  static const String routeName = '/social_login';

  static get route => MaterialPageRoute(
        builder: (context) => const SocialLoginPage(),
        settings: const RouteSettings(name: routeName),
      );

  const SocialLoginPage({super.key});

  @override
  State<SocialLoginPage> createState() => _SocialLoginPageState();
}

class _SocialLoginPageState extends State<SocialLoginPage> {
  bool isVerificationDialogShown = false;

  void _showAgeVerificationDialog(String provider) {
    if (isVerificationDialogShown) return;
    setState(() => isVerificationDialogShown = true);

    AgeVerificationDialog.show(
      context: context,
      provider: provider,
      initialIsAdult: false,
      onConfirm: (isAdult) {
        setState(() => isVerificationDialogShown = false);
        context.read<AuthBloc>().add(
              AuthUpdateConsents(
                isAdult: isAdult,
              ),
            );
      },
      onCancel: () {
        setState(() => isVerificationDialogShown = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthNeedsConsent &&
            ModalRoute.of(context)?.isCurrent == true) {
          _showAgeVerificationDialog(state.provider);
        } else if (state is AuthFailure &&
            (state.operation == "google_sign_in" ||
                state.operation == "apple_sign_in")) {
          showDialog(
            context: context,
            builder: (_) => AuthDialogBox(
              title: "Login Error!",
              description: state.message,
              type: DialogType.error,
              isMultiButton: false,
            ),
          );
        } else if (state is AuthSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => InitialPage()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final isAppleLoading = state is AuthAppleLoading;
        final isGoogleLoading = state is AuthGoogleLoading;

        return EmptyBrandedPage(
          logoImagePath: "assets/images/logo.png",
          bgImagePath: "assets/images/bg.png",
          mainColumnAlignment: MainAxisAlignment.spaceBetween,
          widgets: [
            Platform.isIOS
                ? SocialButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthAppleSignIn());
                    },
                    socialName: 'Apple',
                    isGradient: false,
                    bgColor: ColorPalette.apple,
                    width: Constants.getWidth(context) * 0.53,
                    isIconOnly: true,
                    loaderColor: ColorPalette.apple,
                    isLoading: isAppleLoading,
                  )
                : SocialButton(
                    onPressed: () =>
                        Navigator.of(context).push(SignUpPage.route),
                    socialName: 'Email',
                    isGradient: false,
                    bgColor: Colors.black,
                    width: Constants.getWidth(context) * 0.53,
                    isIconOnly: true,
                    loaderColor: Colors.black,
                    isLoading: false,
                  ),
            const SizedBox(height: 15),
            SocialButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthGoogleSignIn());
              },
              socialName: 'Google',
              isGradient: true,
              bgGradient: ColorPalette.googleGradientsBg,
              width: Constants.getWidth(context) * 0.53,
              isIconOnly: true,
              loaderColor: ColorPalette.primary(ThemeMode.dark),
              isLoading: isGoogleLoading,
            ),
          ],
          newColumnWidgets: [
            const PromoText(text: "Diventa il re della festa."),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: ThemeSizes.xl),
              child: CustomRichText(
                onPressed: () =>
                    Navigator.of(context).push(StandardLoginPage.route),
                initialText: "Oppure accedi",
                richText: "con le tue credenziali",
                richTxtColor: ColorPalette.secondary(ThemeMode.dark),
              ),
            ),
          ],
        );
      },
    );
  }
}
