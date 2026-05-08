import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/dates-and-numbers/number_formatter.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/participant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareableLeaderboardCard extends StatelessWidget {
  static const int _maxVisibleRows = 8;

  final League league;
  final List<Map<String, dynamic>>? membersOverride;
  final ThemeMode themeMode;

  const ShareableLeaderboardCard({
    super.key,
    required this.league,
    this.membersOverride,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final participants = _buildParticipants();
    final visibleCount = participants.length > _maxVisibleRows
        ? _maxVisibleRows
        : participants.length;
    final isTeamBased =
        league.type == LeagueType.team && membersOverride == null;
    final textSecondaryColor = ColorPalette.textSecondary(themeMode);

    return Container(
      color: ColorPalette.bgColor(themeMode),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShareLeaderboardBrandHeader(
            leagueName: league.name,
            themeMode: themeMode,
          ),
          const SizedBox(height: ThemeSizes.md),
          if (participants.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
              child: Text(
                'Nessun partecipante trovato',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: textSecondaryColor,
                ),
              ),
            )
          else ...[
            _ShareLeaderboardHeader(
              isTeamBased: isTeamBased,
              themeMode: themeMode,
            ),
            for (var i = 0; i < visibleCount; i++)
              _ShareLeaderboardRow(
                participant: participants[i],
                position: i + 1,
                themeMode: themeMode,
              ),
            if (participants.length > _maxVisibleRows)
              _ShareLeaderboardEllipsisRow(
                remaining: participants.length - _maxVisibleRows,
                themeMode: themeMode,
              ),
          ],
          const SizedBox(height: ThemeSizes.lg),
          _ShareLeaderboardFooter(themeMode: themeMode),
          const SizedBox(height: ThemeSizes.lg),
        ],
      ),
    );
  }

  List<_ShareLeaderboardParticipant> _buildParticipants() {
    if (membersOverride != null) {
      return membersOverride!.map((member) {
        return _ShareLeaderboardParticipant(
          name: member['name'] as String? ?? '',
          points: _readPoints(member['points']),
          bonusTotal:
              _readPoints(member['bonusTotal'] ?? member['bonus_total']),
          malusTotal:
              _readPoints(member['malusTotal'] ?? member['malus_total']),
        );
      }).toList();
    }

    final participants = List<Participant>.from(league.participants)
      ..sort((a, b) => b.points.compareTo(a.points));

    return participants.map((participant) {
      return _ShareLeaderboardParticipant(
        name: participant.name,
        points: participant.points,
        bonusTotal: participant.bonusTotal,
        malusTotal: participant.malusTotal,
      );
    }).toList();
  }

  double _readPoints(Object? points) {
    if (points is int) return points.toDouble();
    if (points is double) return points;
    if (points is num) return points.toDouble();
    return 0;
  }
}

class _ShareLeaderboardBrandHeader extends StatelessWidget {
  final String leagueName;
  final ThemeMode themeMode;

  const _ShareLeaderboardBrandHeader({
    required this.leagueName,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimaryColor = ColorPalette.textPrimary(themeMode);
    final textSecondaryColor = ColorPalette.textSecondary(themeMode);
    final logoPath = themeMode == ThemeMode.dark
        ? 'assets/images/logos/logo-neon.png'
        : 'assets/images/logos/logo-naked.png';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: ThemeSizes.lg),
        Image.asset(
          logoPath,
          height: 72,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: ThemeSizes.sm),
        Text(
          leagueName.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.passeroOne(
            color: textPrimaryColor,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: ThemeSizes.xs),
        Text(
          "Classifica ufficiale",
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: textSecondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ShareLeaderboardHeader extends StatelessWidget {
  final bool isTeamBased;
  final ThemeMode themeMode;

  const _ShareLeaderboardHeader({
    required this.isTeamBased,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = ColorPalette.primary(themeMode);
    final participantLabel = isTeamBased ? 'Squadra' : 'Giocatore';

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.md,
        horizontal: ThemeSizes.md,
      ),
      margin: const EdgeInsets.only(
        top: ThemeSizes.md,
        bottom: ThemeSizes.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.6),
            primaryColor,
            primaryColor,
            primaryColor,
            primaryColor,
            primaryColor,
            primaryColor.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorPalette.white.withValues(alpha: 0.3),
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(
                Icons.person_outline_rounded,
                color: ColorPalette.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: ThemeSizes.xs),
          Expanded(
            flex: 4,
            child: Text(
              participantLabel,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Bonus',
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                color: ColorPalette.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Malus',
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Punti',
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _ShareLeaderboardRow extends StatelessWidget {
  final _ShareLeaderboardParticipant participant;
  final int position;
  final ThemeMode themeMode;

  const _ShareLeaderboardRow({
    required this.participant,
    required this.position,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimaryColor = ColorPalette.textPrimary(themeMode);
    final textSecondaryColor = ColorPalette.textSecondary(themeMode);
    final secondaryBgColor = ColorPalette.secondaryBgColor(themeMode);
    final points = NumberFormatter.formatPoints(participant.points);
    final bonusTotal = NumberFormatter.formatPoints(participant.bonusTotal);
    final malusTotal = NumberFormatter.formatPoints(participant.malusTotal);
    final medalColor = switch (position) {
      1 => Colors.amber,
      2 => Colors.grey.shade400,
      3 => Colors.brown.shade300,
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.xs),
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.sm,
        horizontal: ThemeSizes.md,
      ),
      decoration: BoxDecoration(
        color: secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: textSecondaryColor.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: medalColor != null
                ? Icon(
                    Icons.emoji_events,
                    color: medalColor,
                    size: 24,
                  )
                : Text(
                    '$position',
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 4,
            child: Text(
              participant.name,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              bonusTotal,
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge?.copyWith(
                color: ColorPalette.success,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              malusTotal,
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge?.copyWith(
                color: ColorPalette.error,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              points,
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _ShareLeaderboardEllipsisRow extends StatelessWidget {
  final int remaining;
  final ThemeMode themeMode;

  const _ShareLeaderboardEllipsisRow({
    required this.remaining,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondaryColor = ColorPalette.textSecondary(themeMode);
    final secondaryBgColor = ColorPalette.secondaryBgColor(themeMode);
    final remainingLabel = remaining == 1 ? '+ 1 altro' : '+ $remaining altri';

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeSizes.xs),
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.sm,
        horizontal: ThemeSizes.md,
      ),
      decoration: BoxDecoration(
        color: secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: textSecondaryColor.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '...',
              style: context.textTheme.titleLarge?.copyWith(
                color: textSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              remainingLabel,
              style: context.textTheme.labelSmall?.copyWith(
                color: textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareLeaderboardFooter extends StatelessWidget {
  final ThemeMode themeMode;

  const _ShareLeaderboardFooter({required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final textPrimaryColor = ColorPalette.textPrimary(themeMode);
    final textSecondaryColor = ColorPalette.textSecondary(themeMode);
    final primaryColor = ColorPalette.primary(themeMode);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: ThemeSizes.md,
        horizontal: ThemeSizes.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.15),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Vivi momenti indimenticabili!',
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              color: textPrimaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: ThemeSizes.xs),
          Text(
            'Gioca anche tu al FantaVacanze!',
            textAlign: TextAlign.center,
            style: context.textTheme.labelMedium?.copyWith(
              color: textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareLeaderboardParticipant {
  final String name;
  final double points;
  final double malusTotal;
  final double bonusTotal;

  const _ShareLeaderboardParticipant({
    required this.name,
    required this.points,
    required this.malusTotal,
    required this.bonusTotal,
  });
}
