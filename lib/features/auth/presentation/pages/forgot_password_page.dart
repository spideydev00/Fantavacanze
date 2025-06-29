import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/auth_dialog_box.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/phone_login_unused/otp_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/auth_field.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/cloudflare_turnstile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const String routeName = '/forgot_password';

  static get route => MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(),
        settings: const RouteSettings(name: routeName),
      );
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String turnstileToken = "";

  // Add a global key to reference the CloudflareTurnstileWidget
  final GlobalKey<CloudflareTurnstileWidgetState> turnstileKey =
      GlobalKey<CloudflareTurnstileWidgetState>();

  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmptyBrandedPage(
      logoImagePath: "assets/images/logo.png",
      bgImagePath: "assets/images/bg.png",
      mainColumnAlignment: MainAxisAlignment.spaceBetween,
      isBackNavigationActive: true,
      widgets: [
        Padding(
          padding: const EdgeInsets.only(bottom: ThemeSizes.xl),
          child: Text(
            "Recupero password",
            style: context.textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
            child: Column(
              children: [
                Text(
                  "Inserisci la tua email per ricevere un codice di recupero",
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: ThemeSizes.lg),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: ThemeSizes.lg),
                  child: CloudflareTurnstileWidget(
                    key: turnstileKey,
                    onTokenReceived: (token) {
                      setState(() => turnstileToken = token);
                    },
                  ),
                ),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthOtpSent) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtpPage(
                            email: emailController.text.trim(),
                            isPasswordReset: true,
                          ),
                        ),
                      );
                    } else if (state is AuthFailure &&
                        state.operation == "send_otp_email") {
                      showDialog(
                        context: context,
                        builder: (_) => AuthDialogBox(
                          title: "Errore",
                          description: state.message,
                          type: DialogType.error,
                          isMultiButton: false,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
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
                                      AuthSendOtpEmail(
                                        email: emailController.text.trim(),
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
                      label: isLoading
                          ? Center(
                              child: Loader(
                                color: ColorPalette.textPrimary(ThemeMode.dark),
                              ),
                            )
                          : const Text("Invia codice"),
                      icon: isLoading
                          ? const SizedBox.shrink()
                          : SvgPicture.asset(
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
    );
  }
}
