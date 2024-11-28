import 'package:fantavacanze_official/core/common/widgets/loader.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/onboarding.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/otp_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/standard_login.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/promo_text.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/rich_text.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/social_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SocialLoginPage extends StatefulWidget {
  //login page route
  static get route =>
      MaterialPageRoute(builder: (context) => const SocialLoginPage());

  const SocialLoginPage({super.key});

  @override
  State<SocialLoginPage> createState() => _SocialLoginPageState();
}

class _SocialLoginPageState extends State<SocialLoginPage> {
  late bool isPhoneButtonPressed;
  late PhoneNumber phoneNumber;
  late bool isValidPhoneNumber;
  final phoneNumberController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isPhoneButtonPressed = false;
    isValidPhoneNumber = false;
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmptyBrandedPage(
      bgImagePath: "images/bg.png",
      mainColumnAlignment: MainAxisAlignment.spaceBetween,
      widgets: [
        /* ----------------------------------------------------------- */
        //Google e Apple login
        Form(
          key: formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthFailure) {
                    showSnackBar(context, state.message);
                  }
                  if (state is AuthSuccess) {
                    Navigator.of(context).push(OnBoardingPage.route);
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
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
                    width: Constants.getWidth(context) * 0.25,
                    isIconOnly: true,
                  );
                },
              ),
              const SizedBox(width: 10),
              SocialButton(
                onPressed: () {},
                socialName: 'Apple',
                isGradient: false,
                bgColor: Colors.black,
                width: Constants.getWidth(context) * 0.25,
                isIconOnly: true,
              ),
            ],
          ),
        ),
        /* ----------------------------------------------------------- */
        //Login con telefono
        const SizedBox(height: 15),
        !isPhoneButtonPressed
            ? SocialButton(
                onPressed: () {
                  setState(
                    () {
                      isPhoneButtonPressed = true;
                    },
                  );
                },
                socialName: "Telefono",
                isGradient: false,
                bgColor: ColorPalette.primary.withOpacity(0.92),
                foregroundColor: ColorPalette.white,
                width: Constants.getWidth(context) * 0.80,
                isIconOnly: false,
              )
            : Column(
                children: [
                  SizedBox(
                    width: Constants.getWidth(context) * 0.90,
                    child: PhoneInputField(
                      controller: phoneNumberController,
                      onTrashIconTap: () {
                        setState(
                          () {
                            isPhoneButtonPressed = false;
                            isValidPhoneNumber = false;
                            phoneNumberController.clear();
                          },
                        );
                      },
                      onInputChanged: (number) {
                        phoneNumber = number;
                      },
                      onInputValidated: (isValidNumber) {
                        setState(() {
                          isValidPhoneNumber = isValidNumber;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isValidPhoneNumber
                        ? () {
                            //Phone SignUp Use-Case

                            //Go to OTP page
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const OtpPage(),
                              ),
                            );
                          }
                        : null, // Disabilitato se non valido
                    style: context.elevatedButtonThemeData.style!.copyWith(
                      elevation: const WidgetStatePropertyAll(1),
                    ),
                    child: const Text(
                      "Richiedi Codice",
                    ),
                  ),
                  if (!isValidPhoneNumber)
                    Padding(
                      padding: const EdgeInsets.only(top: ThemeSizes.md),
                      child: Text(
                        "Inserisci un numero valido.",
                        style: context.textTheme.bodyLarge!.copyWith(
                          color: ColorPalette.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
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
