import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/partner_dashboard_page.dart';
import 'package:flutter/material.dart';

class InvibeBridgePage extends StatelessWidget {
  static const String _slug = 'invibe';

  const InvibeBridgePage({super.key});

  static Route route() {
    return MaterialPageRoute(builder: (_) => const InvibeBridgePage());
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brandPrimaryColor(_slug);

    return EmptyBrandedPage(
      logoImagePath: 'assets/images/logos/logo-neon.png',
      bgImagePath: 'assets/images/invibe-fv-bridge.jpg',
      mainColumnAlignment: MainAxisAlignment.spaceBetween,
      widgets: const [],
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
              Text(
                "Rendi l'estate indimenticabile.",
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
