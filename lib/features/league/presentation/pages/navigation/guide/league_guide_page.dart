import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class LeagueGuidePage extends StatelessWidget {
  const LeagueGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          ThemeSizes.lg,
          ThemeSizes.md,
          ThemeSizes.lg,
          ThemeSizes.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.explore_rounded,
                  size: 48,
                  color: context.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: ThemeSizes.lg),
            Text(
              'Guida al FantaVacanze',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              'Qui trovi le regole principali per usare la lega senza confusione.',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.xl),
            _GuideInfoCard(
              icon: Icons.people_rounded,
              color: context.primaryColor,
              title: 'Lega a squadre o individuale',
              children: const [
                'Una lega a squadre è composta da diversi team, ognuno con un numero diverso di componenti.',
                'Una lega individuale è invece composta dai singoli partecipanti.',
                'CONSIGLIO: Se volete includere anche amiche (o amici) che non partono con voi, quelli che restano a casa creano la lega e le squadre (così da esserne capitani), e voi vi unite al loro team (possono anche fare un\'asta per prendervi). Loro vedranno gli obiettivi che fate e la classifica aggiornata.',
              ],
            ),
            const SizedBox(height: ThemeSizes.md),
            _GuideInfoCard(
              icon: Icons.admin_panel_settings_rounded,
              color: ColorPalette.premiumUser,
              title: 'Admin, bonus e malus',
              children: const [
                'Solo gli admin della lega possono aggiungere bonus e malus.',
                'Gli admin possono nominare altri admin dalla sezione "Admin".',
                'Se vuoi che tutti possano aggiungersi bonus, malus e sfide giornaliere, rendi tutti amministratori.',
              ],
            ),
            const SizedBox(height: ThemeSizes.md),
            _GuideInfoCard(
              icon: Icons.notifications_active_rounded,
              color: ColorPalette.warning,
              title: 'Sfide giornaliere',
              children: const [
                'Ogni partecipante riceve obiettivi giornalieri ogni giorno alle 7 ed avrà 24 ore per completarli.',
                'Per completare una sfida giornaliera, fai scroll col dito verso destra.',
                'Se chi completa la sfida non è admin, agli admin arriva una notifica di approvazione. In una lega in cui tutti sono amministratori, i punti vengono subito aggiunti senza approvazione.',
                'In caso contrario la sfida viene conteggiata solo dopo approvazione dell\'admin. Questo mantiene il controllo sulla lega ed evita imbrogli.',
              ],
            ),
            const SizedBox(height: ThemeSizes.md),
            _GuideInfoCard(
              icon: Icons.home_rounded,
              color: ColorPalette.success,
              title: 'Home e classifica',
              children: const [
                'La Home mostra lo stato della lega, gli obiettivi giornalieri e le azioni più importanti.',
                'La Classifica ordina partecipanti o squadre in base ai punti accumulati.',
                'Bonus, malus e sfide approvate aggiornano il punteggio della classifica.',
              ],
            ),
            const SizedBox(height: ThemeSizes.md),
            _GuideInfoCard(
              icon: Icons.rule_rounded,
              color: ColorPalette.info,
              title: 'Regole e sezioni personali',
              children: const [
                'In "Regole" puoi vedere bonus e malus attivi nella lega.',
                '"La Mia Squadra" raccoglie dati, membri e informazioni della tua squadra (intesa anche come utente individuale).',
                '"Note" serve per annotare ciò che viene fatto, se non si ha subito tempo per assegnarlo.',
              ],
            ),
            const SizedBox(height: ThemeSizes.md),
            _GuideInfoCard(
              icon: Icons.sports_esports_rounded,
              color: context.secondaryColor,
              title: 'Giochi e nuove leghe',
              children: const [
                '"Giochi" contiene mini-giochi pensati per il gruppo, separati dalla gestione admin della lega.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideInfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> children;

  const _GuideInfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
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
        ],
      ),
    );
  }
}
