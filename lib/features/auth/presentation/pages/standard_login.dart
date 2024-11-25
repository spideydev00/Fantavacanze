import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/signup.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/auth_field.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/rich_text.dart';
import 'package:flutter/material.dart';

class StandardLoginPage extends StatelessWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const StandardLoginPage());
  const StandardLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return EmptyBrandedPage(
      bgImagePath: "images/bg.png",
      mainColumnAlignment: MainAxisAlignment.spaceBetween,
      isBackNavigationActive: true,
      widgets: [
        Form(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
            child: Column(
              children: [
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
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text("Accedi"),
                  icon: const Icon(Icons.play_arrow_rounded),
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
