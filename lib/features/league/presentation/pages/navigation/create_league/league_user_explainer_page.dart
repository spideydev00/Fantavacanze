import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/widgets/explainer_info_card.dart';
import 'package:fantavacanze_official/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Schermata mostrata dopo che un utente si unisce a una lega (normale o partner).
/// Stessa grafica della [LeagueAdminExplainerPage] ma con le spiegazioni rivolte
/// a un partecipante non admin.
class LeagueUserExplainerPage extends StatefulWidget {
  const LeagueUserExplainerPage({super.key});

  @override
  State<LeagueUserExplainerPage> createState() =>
      _LeagueUserExplainerPageState();
}

class _LeagueUserExplainerPageState extends State<LeagueUserExplainerPage> {
  bool _showHomeButton = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _showHomeButton = true);
    });
  }

  void _goHome() {
    context.read<AppNavigationCubit>().setIndex(0);

    // Reset all'intero stack sul root navigator: garantisce di tornare alla
    // home reale anche dal flusso partner (dove popUntil(isFirst) si fermava
    // sulla partner dashboard).
    navigatorKey.currentState?.pushAndRemoveUntil(
      DashboardScreen.route,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
        ),
        floatingActionButton: AnimatedScale(
          scale: _showHomeButton ? 1 : 0.8,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: _showHomeButton ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_showHomeButton,
              child: Material(
                color: context.primaryColor,
                elevation: 2,
                shape: const StadiumBorder(),
                child: InkWell(
                  onTap: _goHome,
                  customBorder: const StadiumBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.lg,
                      vertical: ThemeSizes.md,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: ThemeSizes.sm),
                        Text(
                          'Home',
                          style: context.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              ThemeSizes.lg,
              ThemeSizes.md,
              ThemeSizes.lg,
              ThemeSizes.xxl + ThemeSizes.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: ColorPalette.info.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      size: 48,
                      color: ColorPalette.info,
                    ),
                  ),
                ),
                const SizedBox(height: ThemeSizes.lg),
                Text(
                  'Ci sei quasi..',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: ThemeSizes.sm),
                Text(
                  'Ecco come funziona la lega per chi vi partecipa.',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: ThemeSizes.xl),
                ExplainerInfoCard(
                  icon: Icons.rule_folder_rounded,
                  color: ColorPalette.info,
                  title: 'Bonus, malus e classifica',
                  children: const [
                    'Solo gli admin della lega possono assegnare bonus e malus.',
                    'Scala la classifica accumulando punti dalle attività della lega.',
                  ],
                  tips: const [
                    'Vuoi assegnarli anche tu? Chiedi a un admin di renderti amministratore',
                  ],
                ),
                const SizedBox(height: ThemeSizes.md),
                ExplainerInfoCard(
                  icon: Icons.notifications_active_rounded,
                  color: ColorPalette.info,
                  title: 'Sfide giornaliere',
                  children: const [
                    'Sono obiettivi speciali, diversi ogni giorno e che non compaiono nel regolamento.',
                    'Quando completi una sfida, un admin dovrà approvarla prima che venga conteggiata.',
                  ],
                  tips: const [
                    'Completa la sfida e attendi: agli admin arriverà una notifica per approvarla.',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
