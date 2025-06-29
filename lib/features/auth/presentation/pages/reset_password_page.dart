import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/auth_dialog_box.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/standard_login.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class ResetPasswordPage extends StatefulWidget {
  static const String routeName = '/reset_password';

  final String email;
  final String token;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
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
            "Nuova password",
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
                  "Crea una nuova password per il tuo account",
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: ThemeSizes.lg),
                AuthField(
                  controller: passwordController,
                  isPassword: true,
                  hintText: "Nuova password",
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "La password è obbligatoria";
                    }
                    if (value.length < 8) {
                      return "La password deve essere di almeno 8 caratteri";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: ThemeSizes.md),
                AuthField(
                  controller: confirmPasswordController,
                  isPassword: true,
                  hintText: "Conferma password",
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "La conferma password è obbligatoria";
                    }
                    if (value != passwordController.text) {
                      return "Le password non corrispondono";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: ThemeSizes.lg),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthPasswordReset) {
                      showDialog(
                        context: context,
                        builder: (_) => AuthDialogBox(
                          title: "Password modificata",
                          description:
                              "La tua password è stata reimpostata con successo. Puoi ora accedere con la nuova password.",
                          type: DialogType.success,
                          isMultiButton: false,
                          onPrimaryButtonPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const StandardLoginPage()),
                              (route) => false,
                            );
                          },
                        ),
                      );
                    } else if (state is AuthFailure &&
                        state.operation == "reset_password") {
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
                              if (formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                      AuthResetPassword(
                                        email: widget.email,
                                        token: widget.token,
                                        newPassword: passwordController.text,
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
                          : const Text("Reimposta password"),
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
