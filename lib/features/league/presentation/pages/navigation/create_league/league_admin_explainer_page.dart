import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
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

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _AdminInfoCard(
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
              _AdminInfoCard(
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
    );
  }
}

class _AdminInfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> children;
  final List<String> tips;

  const _AdminInfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
    this.tips = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeSizes.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: ThemeSizes.md),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSizes.md),
          ...children.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: ThemeSizes.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.sm),
                  Expanded(
                    child: Text(
                      text,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondaryColor,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...tips.map(
            (text) => Padding(
              padding: const EdgeInsets.only(top: ThemeSizes.xs),
              child: _AdminTip(text: text),
            ),
          ),
        ],
      ),
    );
  }
}

/// Box di risalto per un consiglio, in stile [InfoContainer] con icona a stella.
class _AdminTip extends StatelessWidget {
  final String text;

  const _AdminTip({required this.text});

  @override
  Widget build(BuildContext context) {
    const color = Colors.amber;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: color, size: 20),
              const SizedBox(width: ThemeSizes.sm),
              Text(
                "Consiglio",
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSizes.xs),
          Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondaryColor,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
