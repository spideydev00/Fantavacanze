import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/premium_access_dialog.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/ad_helper.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/features/games/presentation/pages/drink_games_selection.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';

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
                      onPressed: () => _checkPremiumAndNavigate(context),
                      icon: SvgPicture.asset(
                        'assets/images/icons/other/arrow-right-circle.svg',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text('Giochi Alcolici'),
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

  void _checkPremiumAndNavigate(BuildContext context) {
    final userState = context.read<AppUserCubit>().state;
    final isPremium =
        userState is AppUserIsLoggedIn && userState.user.isPremium;

    if (isPremium) {
      Navigator.push(context, DrinkGamesSelection.route);
    } else {
      // Catturo il context “di pagina” prima di aprire il dialog
      final pageContext = context;

      showDialog(
        context: pageContext,
        builder: (_) => PremiumAccessDialog(
          description: "Scegli come sbloccare:",
          onAdsBtnTapped: () => _handleAdsButton(pageContext),
          onPremiumBtnTapped: () => _handlePremiumButton(pageContext),
        ),
      );
    }
  }

  Future<void> _handleAdsButton(BuildContext pageContext) async {
    final navigator = Navigator.of(pageContext);

    // Mostra overlay di caricamento
    final loadingOverlay = _showLoadingOverlay(pageContext);

    try {
      final adHelper = serviceLocator<AdHelper>();

      // Esegue gli ads in sequenza
      final bool adsWatched = await adHelper.showSequentialRewardedAds();

      // Rimuovo overlay
      if (loadingOverlay.mounted) loadingOverlay.remove();

      // Se la pagina è ancora montata, procedo
      if (!pageContext.mounted) return;

      if (adsWatched) {
        showSnackBar(
          "Accesso sbloccato con successo!",
          color: ColorPalette.success,
        );
        await Future.delayed(const Duration(milliseconds: 300));

        navigator.push(DrinkGamesSelection.route);
      } else {
        showSnackBar(
          "Non è stato possibile completare la visione degli annunci. Riprova tra qualche minuto.",
          color: ColorPalette.error,
        );
      }
    } catch (e) {
      debugPrint('Error in _handleAdsButton: $e');
      if (loadingOverlay.mounted) loadingOverlay.remove();
      if (pageContext.mounted) {
        showSnackBar(
          "Si è verificato un errore. Riprova più tardi.",
          color: ColorPalette.error,
        );
      }
    }
  }

  void _handlePremiumButton(BuildContext context) {
    // TODO: Implement premium subscription flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Funzionalità premium in arrivo",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ColorPalette.premiumGradient[1],
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  OverlayEntry _showLoadingOverlay(BuildContext context) {
    final overlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Loader(color: context.primaryColor),
      ),
    );

    Overlay.of(context).insert(overlay);
    return overlay;
  }
}
