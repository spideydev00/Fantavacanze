import 'package:fantavacanze_official/core/common/widgets/loader.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/custom_dialog_box.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/standard_login.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/auth_field.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/cloudflare_turnstile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SignUpPage extends StatefulWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const SignUpPage());
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String turnstileToken = "";

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmptyBrandedPage(
      bgImagePath: "assets/images/bg.png",
      isBackNavigationActive: true,
      mainColumnAlignment: MainAxisAlignment.start,
      widgets: [
        Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
            child: Column(
              children: [
                AuthField(
                  controller: nameController,
                  hintText: "Nome",
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeSizes.sm,
                      horizontal: ThemeSizes.md,
                    ),
                    child: SvgPicture.asset(
                      "assets/images/icons/auth_field_icons/user-icon.svg",
                      width: 35,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                      width: 35,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: ThemeSizes.lg),
                  child: CloudflareTurnstileWidget(
                    onTokenReceived: (token) {
                      setState(() {
                        turnstileToken = token;
                      });

                      // print("Token: $turnstileToken");
                    },
                  ),
                ),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthFailure) {
                      showDialog(
                        context: context,
                        builder: (context) => CustomDialogBox(
                          title: "Errore!",
                          description: state.message,
                          type: DialogType.error,
                          isMultiButton: false,
                        ),
                      );
                    }
                    if (state is AuthSuccess) {
                      Navigator.of(context).pushAndRemoveUntil(
                          StandardLoginPage.route, (route) => false);
                      showDialog(
                        context: context,
                        builder: (context) => CustomDialogBox(
                          title: "Ottimo!",
                          description:
                              "Attiva l'account cliccando sul link che ti è stato inviato per e-mail",
                          buttonText: "Ok",
                          type: DialogType.success,
                          isMultiButton: false,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(
                        child: Loader(
                          color: ColorPalette.primary,
                        ),
                      );
                    }
                    return ElevatedButton(
                      onPressed: () {
                        if (turnstileToken.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => CustomDialogBox(
                              title: "hCaptcha Error..",
                              description: "Dimostra di essere un umano!",
                              type: DialogType.error,
                              isMultiButton: false,
                            ),
                          );
                        }
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                AuthEmailSignUp(
                                  name: nameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  hCaptcha: turnstileToken,
                                ),
                              );
                        }
                      },
                      child: const Text("Registrati Ora"),
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
