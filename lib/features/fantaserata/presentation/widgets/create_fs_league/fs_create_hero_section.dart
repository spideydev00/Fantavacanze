import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class FsCreateHeroSection extends StatelessWidget {
  final FsNightType nightType;

  const FsCreateHeroSection({
    super.key,
    this.nightType = FsNightType.def,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ColorPalette.getSeasonalGradient(nightType),
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: ThemeSizes.md),
          Text(
            _getSeasonalTitle(),
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeSizes.sm),
          Text(
            _getSeasonalSubtitle(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get seasonal title based on night type
  String _getSeasonalTitle() {
    switch (nightType) {
      case FsNightType.halloween:
        return 'Chi Sopravviverà Alla Notte?';
      case FsNightType.christmas:
        return 'Chi Sarà Il Re Della Vigilia?';
      case FsNightType.carnival:
        return 'Chi Sarà Il Re Del Carnevale?';
      case FsNightType.newYearsEve:
        return 'Chi Entrerà Nel Nuovo Anno Da Vincitore?';
      case FsNightType.apresSki:
        return 'Chi Dominerà Le Piste?';
      default:
        return 'Chi Vincerà La Serata?';
    }
  }

  /// Get seasonal subtitle based on night type
  String _getSeasonalSubtitle() {
    switch (nightType) {
      case FsNightType.halloween:
        return 'Crea una serata da brivido e invita i tuoi amici per una notte UNICA!';
      case FsNightType.christmas:
        return 'Crea una lega natalizia e invita i tuoi amici per una serata magica';
      case FsNightType.carnival:
        return 'Crea una lega di carnevale e invita i tuoi amici per una serata colorata';
      case FsNightType.newYearsEve:
        return 'Crea una lega di Capodanno e invita i tuoi amici per vivere insieme l\'ultimo dell\'anno!';
      case FsNightType.apresSki:
        return 'Crea una lega sulla neve e invita i tuoi amici per una serata ghiacciata';
      default:
        return 'Crea la tua lega e invita i tuoi amici per una serata indimenticabile';
    }
  }
}
