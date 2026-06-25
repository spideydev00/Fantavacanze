import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/brand_assets.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PartnerThankYouPage extends StatelessWidget {
  final String slug;

  const PartnerThankYouPage({
    super.key,
    required this.slug,
  });

  static Route route(String slug) {
    return MaterialPageRoute(
      builder: (_) => PartnerThankYouPage(slug: slug),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<AppThemeCubit>().isDarkMode(context);
    final brandColor = context.brandPrimaryColor(slug);
    final partnerLogo = BrandAssets.logoFor(slug, isDark: isDark);
    final content = _content(slug);

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Grazie'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeSizes.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (partnerLogo != null) ...[
                    Image.asset(
                      partnerLogo,
                      height: ThemeSizes.imageThumbSizeLg,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ],
                  const SizedBox(height: ThemeSizes.xl),
                  Text(
                    'Grazie di cuore ❤️',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: brandColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  Text(
                    content.body,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.textPrimaryColor,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

({String partnerName, String body}) _content(String slug) {
  return switch (slug) {
    'b-eazy' => (
        partnerName: 'b-eazy',
        body:
            'Fantavacanze e b-eazy ringraziano di cuore te e tutti i partecipanti per aver vissuto questa esperienza al massimo. Senza di voi non sarebbe la stessa cosa: continuate a divertirvi e a creare ricordi! 🎉',
      ),
    _ => (
        partnerName: 'InVibe',
        body:
            "Fantavacanze e InVibe ringraziano di cuore te e tutti i partecipanti per aver reso questa vacanza un'avventura indimenticabile. Ogni sfida, ogni risata e ogni ricordo li avete creati voi. Che la vostra estate sia leggendaria! 🌊☀️",
      ),
  };
}
