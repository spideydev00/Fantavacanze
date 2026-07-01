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

class LeagueAdminExplainerPage extends StatefulWidget {
  const LeagueAdminExplainerPage({super.key});

  @override
  State<LeagueAdminExplainerPage> createState() =>
      _LeagueAdminExplainerPageState();
}

class _LeagueAdminExplainerPageState extends State<LeagueAdminExplainerPage> {
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
                    Icons.admin_panel_settings_rounded,
                    size: 48,
                    color: ColorPalette.info,
                  ),
                ),
              ),
              const SizedBox(height: ThemeSizes.lg),
              Text(
                'Prima di iniziare..',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: ThemeSizes.sm),
              Text(
                'Queste regole servono a mantenere la lega controllata e ad evitare imbrogli.',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: ThemeSizes.xl),
              ExplainerInfoCard(
                icon: Icons.rule_folder_rounded,
                color: ColorPalette.info,
                title: 'Bonus, malus e nuovi admin',
                children: const [
                  'Solo gli admin della lega possono aggiungere bonus e malus.',
                  'Puoi nominare nuovi admin dalla sezione "Admin".',
                ],
                tips: const [
                  'All\'inizio l\'unico admin è il creatore.',
                  'Se vuoi che tutti i partecipanti possano aggiungersi bonus, malus e sfide giornaliere, rendi tutti amministratori da quella pagina.',
                ],
              ),
              const SizedBox(height: ThemeSizes.md),
              ExplainerInfoCard(
                icon: Icons.notifications_active_rounded,
                color: ColorPalette.info,
                title: 'Sfide giornaliere',
                children: const [
                  'Si tratta di obiettivi speciali, diversi ogni giorno e che non compaiono nel regolamento.',
                  'Un admin dovrà approvare o rifiutare la sfida prima che venga conteggiata.',
                  'Se il partecipante è già admin, la sfida viene accettata direttamente.',
                ],
                tips: [
                  'Se un partecipante non admin completa una sfida giornaliera, agli admin arriverà una notifica.',
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
