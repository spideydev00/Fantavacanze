import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/auth_field.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/promo_text.dart';
import 'package:flutter/material.dart';

class PostOtpVerification extends StatelessWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const PostOtpVerification());
  const PostOtpVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return EmptyBrandedPage(
      bgImagePath: "images/insert-name.jpg",
      mainColumnAlignment: MainAxisAlignment.start,
      widgets: [
        SizedBox(height: Constants.getHeight(context) * 0.18),
        const Padding(
          padding: EdgeInsets.all(ThemeSizes.lg),
          child: PromoText(text: "Sei ad un passo."),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(ThemeSizes.lg),
          child: AuthField(
              controller: nameController, hintText: "Come ti chiami?"),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          label: const Text("Inizia Ora"),
          icon: const Icon(Icons.scatter_plot_outlined),
        )
      ],
    );
  }
}
