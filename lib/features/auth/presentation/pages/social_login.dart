import 'dart:io';
import 'package:fantavacanze_official/core/common/widgets/loader.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/onboarding.dart';
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
      bgImagePath: "images/bg.png",
      mainColumnAlignment: MainAxisAlignment.spaceBetween,
      widgets: [
        /* ----------------------------------------------------------- */
        //Discord e Apple(Facebook) login
        Form(
          key: formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialButton(
                onPressed: () {},
                socialName: 'Discord',
                isGradient: false,
                bgColor: const Color.fromARGB(255, 103, 125, 205),
                width: Constants.getWidth(context) * 0.25,
                isIconOnly: true,
              ),
              const SizedBox(width: 10),
              // ------------------------------------------- //
              // -- APPLE LOGIN or FACEBOOK LOGIN -- //
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthFailure) {
                    showSnackBar(context, state.message);
                  }
                  if (state is AuthSuccess) {
                    Navigator.of(context).pushAndRemoveUntil(
                        OnBoardingScreen.route, (route) => false);
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: ThemeSizes.xl),
                        child: Loader(
                          color: Platform.isIOS
                              ? Colors.black
                              : const Color.fromARGB(255, 32, 71, 134),
                        ),
                      ),
                    );
                  }
                  return Platform.isIOS
                      ? SocialButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthAppleSignIn());
                          },
                          socialName: 'Apple',
                          isGradient: false,
                          bgColor: Colors.black,
                          width: Constants.getWidth(context) * 0.25,
                          isIconOnly: true,
                        )
                      : SocialButton(
                          onPressed: () {},
                          socialName: 'Facebook',
                          isGradient: false,
                          bgColor: const Color.fromARGB(255, 32, 71, 134),
                          width: Constants.getWidth(context) * 0.25,
                          isIconOnly: true,
                        );
                },
              ),
            ],
          ),
        ),
        //Login con Google
        const SizedBox(height: 15),
        BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackBar(context, state.message);
            }
            if (state is AuthSuccess) {
              Navigator.of(context)
                  .pushAndRemoveUntil(OnBoardingScreen.route, (route) => false);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
                  child: Loader(
                    color: ColorPalette.primary,
                  ),
                ),
              );
            }
            return SocialButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthGoogleSignIn());
              },
              socialName: 'Google',
              isGradient: true,
              bgGradient: ColorPalette.googleGradientsBg,
              width: Constants.getWidth(context) * 0.53,
              isIconOnly: true,
            );
          },
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
