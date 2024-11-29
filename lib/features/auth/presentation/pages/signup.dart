import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/auth_field.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const SignUpPage());
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();

    return EmptyBrandedPage(
      bgImagePath: "images/bg.png",
      isBackNavigationActive: true,
      mainColumnAlignment: MainAxisAlignment.start,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: ColorPalette.white,
      ),
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
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () {},
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
