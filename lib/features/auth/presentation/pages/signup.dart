import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/auth_field.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const SignUpPage());
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    late String turnstileToken;

    final TurnstileOptions options = TurnstileOptions(
      size: TurnstileSize.normal,
      theme: TurnstileTheme.light,
      language: 'IT',
      retryAutomatically: false,
      refreshTimeout: TurnstileRefreshTimeout.auto,
      borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
    );

    return EmptyBrandedPage(
      bgImagePath: "images/bg.png",
      isBackNavigationActive: true,
      mainColumnAlignment: MainAxisAlignment.start,
      widgets: [
        Form(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
            child: Column(
              children: [
                AuthField(
                  controller: nameController,
                  hintText: "Nome",
                ),
                const SizedBox(height: 12),
                AuthField(
                  controller: emailController,
                  hintText: "E-mail",
                ),
                const SizedBox(height: 12),
                AuthField(
                  controller: passwordController,
                  isPassword: true,
                  hintText: "Password",
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: ThemeSizes.lg),
                  child: CloudflareTurnstile(
                    siteKey: AppSecrets.turnstileKey,
                    baseUrl: AppSecrets.supabaseUrl,
                    options: options,
                    onTokenReceived: (token) {
                      setState(() {
                        turnstileToken = token;
                      });

                      // print("Token: $turnstileToken");
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (turnstileToken.isEmpty) {
                      //return dialog
                    }

                    //sign in and go to home page
                  },
                  label: const Text("Registrati Ora!"),
                  icon: const Icon(Icons.person_add_alt_1_sharp),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
