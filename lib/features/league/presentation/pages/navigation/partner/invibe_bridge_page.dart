import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/brand_theme.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/promo_text.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/partner_dashboard_page.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvibeBridgePage extends StatelessWidget {
  static const String _slug = 'invibe';

  // Chiave SharedPreferences: bridge mostrato una sola volta per utente.
  static const String _seenKeyPrefix = 'invibe_bridge_seen_';

  const InvibeBridgePage({super.key});

  static String _seenKey() {
    final state = serviceLocator<AppUserCubit>().state;
    final userId = state is AppUserIsLoggedIn ? state.user.id : 'guest';
    return '$_seenKeyPrefix$userId';
  }

  /// Mostra il bridge solo la prima volta per utente; le volte successive
  /// va dritto alla dashboard partner.
  static Route route() {
    final prefs = serviceLocator<SharedPreferences>();

    if (prefs.getBool(_seenKey()) ?? false) {
      return PartnerDashboardPage.route(_slug);
    }

    prefs.setBool(_seenKey(), true);
    return MaterialPageRoute(builder: (_) => const InvibeBridgePage());
  }

  @override
  Widget build(BuildContext context) {
    final brand = BrandThemes.of(_slug)!.primaryLight;

    return EmptyBrandedPage(
      logoImagePath: 'assets/images/logos/logo-neon.png',
      bgImagePath: 'assets/images/invibe-fv-bridge.jpg',
      mainColumnAlignment: MainAxisAlignment.spaceBetween,
      widgets: const [],
      hasTopShadow: true,
      newColumnWidgets: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ThemeSizes.lg,
            0,
            ThemeSizes.lg,
            ThemeSizes.xl,
          ),
          child: Column(
            children: [
              PromoText(text: "Vivi un'esperienza unica."),
              const SizedBox(height: ThemeSizes.lg),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  PartnerDashboardPage.route(_slug),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: brand),
                child: const Text('Continua'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
