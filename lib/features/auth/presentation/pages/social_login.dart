import 'dart:io';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/signup.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/standard_login.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/promo_text.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/rich_text.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/social_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialLoginPage extends StatefulWidget {
  //login page route
  static get route =>
      MaterialPageRoute(builder: (context) => const SocialLoginPage());

  const SocialLoginPage({super.key});

  @override
  State<SocialLoginPage> createState() => _SocialLoginPageState();
}

class _SocialLoginPageState extends State<SocialLoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late String turnstileToken;

  @override
  void initState() {
    super.initState();
    turnstileToken = '';
  }

  @override
  Widget build(BuildContext context) {
    return EmptyBrandedPage(
      bgImagePath: "assets/images/bg.png",
      mainColumnAlignment: MainAxisAlignment.spaceBetween,
      widgets: [
        /* ----------------------------------------------------------- */
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
                loadingState: AuthAppleOrFbLoading(),
              )
            : SocialButton(
                onPressed: () {
                  Navigator.of(context).push(SignUpPage.route);
                },
                socialName: 'Email',
                isGradient: false,
                bgColor: ColorPalette.primary,
                width: Constants.getWidth(context) * 0.53,
                isIconOnly: true,
                loaderColor: ColorPalette.primary,
                loadingState: AuthAppleOrFbLoading(),
              ),
        //Login con Google
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
          loaderColor: ColorPalette.primary,
          loadingState: AuthGoogleLoading(),
        ),
      ],
      newColumnWidgets: [
        /* ----------------------------------------------------------- */
        //Testo nella parte bassa della pagina
        const PromoText(text: "Diventa il re della festa."),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ThemeSizes.xl),
          child: CustomRichText(
            onPressed: () {
              Navigator.of(context).push(StandardLoginPage.route);
            },
            initialText: "Oppure accedi",
            richText: "con le tue credenziali",
            richTxtColor: ColorPalette.secondary,
          ),
        ),
      ],
    );
  }
}
