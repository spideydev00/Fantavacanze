import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/standard_login.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/promo_text.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/rich_text.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/social_button.dart';
import 'package:flutter/material.dart';

class SocialLoginPage extends StatelessWidget {
  //login page route
  static get route =>
      MaterialPageRoute(builder: (context) => const SocialLoginPage());

  const SocialLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyBrandedPage(
      bgImagePath: "images/bg.png",
      mainColumnAlignment: MainAxisAlignment.spaceBetween,
      widgets: [
        /* ----------------------------------------------------------- */
        //Google e Apple login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialButton(
              onPressed: () {},
              socialName: 'Google',
              isGradient: true,
              bgGradient: ColorPalette.googleGradientsBg,
              width: Constants.getWidth(context) * 0.25,
              isIconOnly: true,
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
        /* ----------------------------------------------------------- */
        //Login con telefono
        const SizedBox(height: 15),
        SocialButton(
          onPressed: () {},
          socialName: "Telefono",
          isGradient: false,
          bgColor: ColorPalette.greenContainer,
          width: Constants.getWidth(context) * 0.80,
          isIconOnly: false,
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
