import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/action_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/invibe_bridge_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PartnerEntrySection extends StatelessWidget {
  static const String _partnerSlug = 'invibe';

  const PartnerEntrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(_partnerSlug);

    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
              child: CustomDivider(
                text: 'InVibe',
                imagePath: state.themeMode == ThemeMode.dark
                    ? "assets/images/logos/invibe.png"
                    : "assets/images/logos/invibe-naked.png",
                color: brandColor,
                thickness: state.themeMode == ThemeMode.dark ? 0.25 : 0.75,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ActionCard(
                    title: "Leghe InVibe",
                    imagePath: "assets/images/invibe-card-bg.jpeg",
                    onTap: () {
                      // --- "Mostra una volta sola" il ponte InVibe (DA ATTIVARE) ---
                      // final flags = Hive.box('app_flags'); // box da aprire all'avvio
                      // final seen = flags.get(
                      //   'invibe_bridge_seen',
                      //   defaultValue: false,
                      // ) as bool;
                      // if (seen) {
                      //   Navigator.push(context, PartnerDashboardPage.route('invibe'));
                      // } else {
                      //   flags.put('invibe_bridge_seen', true);
                      //   Navigator.push(context, InvibeBridgePage.route());
                      // }
                      // --- fino ad allora: mostra SEMPRE il ponte (per rifinitura grafica) ---
                      Navigator.push(context, InvibeBridgePage.route());
                    },
                    iconData: Icons.arrow_circle_right_outlined,
                    iconGlowColor: context.brandPrimaryColor("invibe"),
                    description:
                        "Sei dei nostri? Clicca qui per creare o unirti a una lega.",
                    showBottomGradient: true,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
