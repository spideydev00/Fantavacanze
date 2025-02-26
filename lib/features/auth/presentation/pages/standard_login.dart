import 'package:fantavacanze_official/core/common/widgets/loader.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/custom_dialog_box.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/signup.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/auth_field.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/cloudflare_turnstile_widget.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/rich_text.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class StandardLoginPage extends StatefulWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const StandardLoginPage());
  const StandardLoginPage({super.key});

  @override
  State<StandardLoginPage> createState() => _StandardLoginPageState();
}

class _StandardLoginPageState extends State<StandardLoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String turnstileToken = "";

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmptyBrandedPage(
      bgImagePath: "images/bg.png",
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
                      "images/add-email-icon.svg",
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
                      "images/lock-icon.svg",
                      width: 33,
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
                          title: "Errore Login!",
                          description: state.message,
                          type: DialogType.error,
                          isMultiButton: false,
                        ),
                      );
                    }
                    if (state is AuthSuccess) {
                      Navigator.of(context).pushAndRemoveUntil(
                          DashboardScreen.route, (route) => false);
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
                    return ElevatedButton.icon(
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
                                AuthEmailSignIn(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  hCaptcha: turnstileToken,
                                ),
                              );
                        }
                      },
                      label: const Text("Accedi"),
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ],
      newColumnWidgets: [
        /* ----------------------------------------------------------- */
        //Testo nella parte bassa della pagina
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ThemeSizes.xl),
          child: CustomRichText(
            onPressed: () {
              Navigator.of(context).push(SignUpPage.route);
            },
            initialText: "Non hai un account?",
            richText: "Crealo ora.",
            richTxtColor: ColorPalette.secondary,
          ),
        ),
      ],
    );
  }
}
