import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/auth_dialog_box.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/signup.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/age_verification_dialog.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/auth_field.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/cloudflare_turnstile_widget.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/rich_text.dart';
import 'package:fantavacanze_official/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class StandardLoginPage extends StatefulWidget {
  static const String routeName = '/standard_login';

  static get route => MaterialPageRoute(
        builder: (context) => const StandardLoginPage(),
        settings: const RouteSettings(name: routeName),
      );
  const StandardLoginPage({super.key});

  @override
  State<StandardLoginPage> createState() => _StandardLoginPageState();
}

class _StandardLoginPageState extends State<StandardLoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String turnstileToken = "";
  bool isVerificationDialogShown = false;

  // Add a global key to reference the CloudflareTurnstileWidget
  final GlobalKey<CloudflareTurnstileWidgetState> turnstileKey =
      GlobalKey<CloudflareTurnstileWidgetState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showAgeVerificationDialog() {
    if (isVerificationDialogShown) return;

    setState(() => isVerificationDialogShown = true);
    AgeVerificationDialog.show(
      context: context,
      provider: 'Email',
      initialIsAdult: false,
      onConfirm: (isAdult) {
        setState(() => isVerificationDialogShown = false);

        // Update consents but don't auto-retry login
        context.read<AuthBloc>().add(
              AuthUpdateConsents(
                isAdult: isAdult,
              ),
            );

        // Reset captcha widget after updating consents
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Reset the widget using the key
          turnstileKey.currentState?.resetWidget();

          // Clear the token
          setState(() => turnstileToken = "");

          showSnackBar(
            "Consensi aggiornati! Completa il captcha e prova a fare il login.",
            color: ColorPalette.success,
          );
        });
      },
      onCancel: () {
        setState(() => isVerificationDialogShown = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EmptyBrandedPage(
      logoImagePath: "assets/images/logo.png",
      bgImagePath: "assets/images/bg.png",
      mainColumnAlignment: MainAxisAlignment.spaceBetween,
      isBackNavigationActive: true,
      widgets: [
        Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
            child: Column(
              children: [
                AuthField(
                  controller: emailController,
                  hintText: "E-mail",
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeSizes.sm,
                      horizontal: ThemeSizes.md,
                    ),
                    child: SvgPicture.asset(
                      "assets/images/icons/auth_field_icons/add-email-icon.svg",
                      width: 35,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AuthField(
                  controller: passwordController,
                  isPassword: true,
                  hintText: "Password",
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeSizes.sm,
                      horizontal: ThemeSizes.md,
                    ),
                    child: SvgPicture.asset(
                      "assets/images/icons/auth_field_icons/lock-icon.svg",
                      width: 33,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(ForgotPasswordPage.route);
                    },
                    child: Text(
                      "Hai dimenticato la password?",
                      style: context.textTheme.labelMedium!.copyWith(
                        color: context.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: ThemeSizes.lg),
                  child: CloudflareTurnstileWidget(
                    key: turnstileKey, // Use the global key here
                    onTokenReceived: (token) {
                      setState(() => turnstileToken = token);
                    },
                  ),
                ),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthNeedsConsent &&
                        ModalRoute.of(context)?.isCurrent == true) {
                      _showAgeVerificationDialog();
                    } else if (state is AuthConsentsUpdated) {
                      showSnackBar(
                        "Consensi aggiornati! Ora riprova a fare il login.",
                        color: ColorPalette.success,
                      );
                    } else if (state is AuthFailure &&
                        state.operation == "email_sign_in") {
                      showDialog(
                        context: context,
                        builder: (_) => AuthDialogBox(
                          title: "Errore di accesso",
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
                    if (state is AuthLoading) {
                      return Center(
                        child: Loader(
                          color: ColorPalette.primary(ThemeMode.dark),
                        ),
                      );
                    }
                    return ElevatedButton.icon(
                      onPressed: () {
                        if (turnstileToken.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (_) => AuthDialogBox(
                              title: "hCaptcha Error..",
                              description: "Dimostra di essere un umano!",
                              type: DialogType.error,
                              isMultiButton: false,
                            ),
                          );
                          return;
                        }
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                AuthEmailSignIn(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  hCaptcha: turnstileToken,
                                ),
                              );
                        }
                      },
                      style: context.elevatedButtonThemeData.style!.copyWith(
                        backgroundColor: WidgetStatePropertyAll(
                            ColorPalette.primary(ThemeMode.dark)),
                        foregroundColor: WidgetStatePropertyAll(
                            ColorPalette.textPrimary(ThemeMode.dark)),
                      ),
                      label: const Text("Accedi"),
                      icon: SvgPicture.asset(
                        "assets/images/icons/auth_icons/sign-in-icon.svg",
                        width: 25,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ],
      newColumnWidgets: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ThemeSizes.xl),
          child: CustomRichText(
            onPressed: () => Navigator.of(context).push(SignUpPage.route),
            initialText: "Non hai un account?",
            richText: "Crealo ora.",
            richTxtColor: ColorPalette.secondary(ThemeMode.dark),
          ),
        ),
      ],
    );
  }
}
