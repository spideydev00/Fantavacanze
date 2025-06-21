import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/features/games/presentation/pages/game_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/premium_access_dialog.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/services/ad_helper.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';

class DrinkGames extends StatelessWidget {
  static const String routeName = '/drink_games';
  static Route get route => MaterialPageRoute(
        builder: (_) => const DrinkGames(),
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
              // Sfondo semi-trasparente con l'icona dei dadi
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/images/icons/homepage_icons/friends-hug-icon.png',
                    height: MediaQuery.of(context).size.height * 0.45,
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner informativo in alto
                  InfoBanner(
                    message:
                        'In questa sezione puoi accedere ai giochi proposti dal team Fantavacanze.',
                    color: context.colorScheme.primary,
                    icon: Icons.celebration,
                  ),

                  const SizedBox(height: ThemeSizes.sm),

                  Text(
                    'Se vuoi dare un tocco in più alle tue serate, interagire con nuove persone o semplicemente divertirti con i tuoi amici e le tue amiche, questa sezione fa per te!',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  // Pulsante centrale “Giochi”
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _onPlayTapped(context),
                      icon: SvgPicture.asset(
                        'assets/images/icons/other/arrow-right-circle.svg',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text('Giochi'),
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

  Future<void> _onPlayTapped(BuildContext context) async {
    final adHelper = AdHelper();

    // Se siamo ancora in sessione drink games, vai subito
    if (adHelper.isDrinkGamesSessionActive()) {
      _navigateToGames(context);
      return;
    }

    // Controllo se l'utente è premium
    final userState = context.read<AppUserCubit>().state;
    final isPremium =
        userState is AppUserIsLoggedIn && userState.user.isPremium;

    if (isPremium) {
      _navigateToGames(context);
      return;
    }

    // Mostro il dialog e attendo il risultato:
    // - true  = accesso garantito (ads guardate con successo)
    // - false = premium o chiusura manuale
    final accessGranted = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (_) => PremiumAccessDialog(
            description: "Scegli come sbloccare:",
            // Ads: ritorna Future<bool>
            onAdsBtnTapped: () async {
              late bool granted;
              try {
                granted = await adHelper.showRewardedAd(context);
              } catch (e) {
                granted = true;
              }

              // Mostro lo snack solo se ha guadagnato il reward
              if (granted) {
                showSnackBar(
                  "Giochi sbloccati per 15 minuti!",
                  color: ColorPalette.success,
                );
              }

              return granted;
            },
          ),
        ) ??
        false;

    if (accessGranted) {
      if (context.mounted) {
        adHelper.grantDrinkGamesAccess();

        _navigateToGames(context);
      }
    }
  }

  void _navigateToGames(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      GameSelectionPage.route,
      (route) => false,
    );
  }
}
