import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/premium_access_dialog.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/ad_helper.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/features/games/presentation/pages/drink_games_selection.dart';

class DrinkGames extends StatelessWidget {
  static const String routeName = '/drink_games';

  static get route => MaterialPageRoute(
        builder: (context) => const DrinkGames(),
        settings: const RouteSettings(name: routeName),
      );

  const DrinkGames({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.lg),
          child: Stack(
            children: [
              // Background SVG icon
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.15,
                  child: SvgPicture.asset(
                    'assets/images/icons/homepage_icons/drink-games-page-icon.svg',
                    height: MediaQuery.of(context).size.height * 0.40,
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info banner at the top
                  InfoBanner(
                    message:
                        'In questa sezione puoi accedere ai giochi alcolici proposti dal team Fantavacanze.',
                    color: Theme.of(context).colorScheme.primary,
                    icon: Icons.celebration,
                  ),

                  SizedBox(height: ThemeSizes.sm),

                  Text(
                    'Se vuoi dare un tocco in più alle tue serate, interagire con nuove persone o semplicemente divertirti con i tuoi amici e le tue amiche, questa sezione fa per te!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const Spacer(),

                  // Central button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => PremiumAccessDialog(
                            description: "Scegli come sbloccare: ",
                            onAdsBtnTapped: () => _handleAdsButton(context),
                            onPremiumBtnTapped: () =>
                                _handlePremiumButton(context),
                          ),
                        );
                      },
                      icon: SvgPicture.asset(
                          'assets/images/icons/other/arrow-right-circle.svg'),
                      label: const Text(
                        'Giochi Alcolici',
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle ads button tap
  Future<void> _handleAdsButton(BuildContext context) async {
    // Show loading dialog
    final loadingOverlay = _showLoadingOverlay(context);

    try {
      final adHelper = GetIt.instance<AdHelper>();

      // Show first rewarded ad
      debugPrint('Showing first rewarded ad...');
      final bool firstAdWatched = await adHelper.showRewardedAd();

      if (!firstAdWatched) {
        // If first ad fails, show error and return
        loadingOverlay.remove();
        showSnackBar(
          "Non è stato possibile mostrare la pubblicità. Riprova più tardi.",
          color: ColorPalette.error,
        );
        return;
      }

      // Small delay between ads
      await Future.delayed(const Duration(milliseconds: 500));

      // Show second rewarded ad
      debugPrint('Showing second rewarded ad...');
      final bool secondAdWatched = await adHelper.showRewardedAd();

      loadingOverlay.remove();

      if (secondAdWatched) {
        // Successfully watched both ads, navigate to games selection
        if (context.mounted) {
          Navigator.push(context, DrinkGamesSelection.route);
        }

        // Show success message
        showSnackBar(
          "Accesso sbloccato con successo!",
          color: ColorPalette.success,
        );
      } else {
        // Failed to earn reward
        showSnackBar(
          "Non è stato possibile completare la visione degli annunci.",
          color: ColorPalette.error,
        );
      }
    } catch (e) {
      // Handle any errors
      loadingOverlay.remove();
      showSnackBar(
        "Si è verificato un errore. Riprova più tardi.",
        color: ColorPalette.error,
      );
    }
  }

  void _handlePremiumButton(BuildContext context) {
    // TODO: Implement premium subscription flow
    showSnackBar(
      "Funzionalità premium in arrivo!",
      color: ColorPalette.warning,
    );
  }

  // Helper method to show a loading overlay
  OverlayEntry _showLoadingOverlay(BuildContext context) {
    final overlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    return overlay;
  }
}
