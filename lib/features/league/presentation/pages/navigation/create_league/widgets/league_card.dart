import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:intl/intl.dart';

class LeagueCard extends StatelessWidget {
  final League league;
  final VoidCallback onTap;

  const LeagueCard({
    super.key,
    required this.league,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final participantsCount = league.participants.length;
    final formattedDate = DateFormat('dd/MM/yyyy').format(league.createdAt);

    // Get invite code if available (from LeagueModel)
    final String? inviteCode =
        league is LeagueModel ? (league as LeagueModel).inviteCode : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      league.name,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeSizes.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: league.isTeamBased
                          ? Colors.blue.withValues(alpha: 0.2)
                          : ColorPalette.success.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusMd),
                    ),
                    child: Text(
                      league.isTeamBased ? 'Squadre' : 'Individuale',
                      style: TextStyle(
                        color: league.isTeamBased
                            ? Colors.blue
                            : ColorPalette.success,
                        fontWeight: FontWeight.bold,
                        fontSize: ThemeSizes.labelMd,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ThemeSizes.sm),
              Text(
                league.description!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: ThemeSizes.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people,
                          size: 16, color: context.textSecondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '$participantsCount ${participantsCount == 1 ? 'partecipante' : 'partecipanti'}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: context.textSecondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Creato il: $formattedDate',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Show invite code if available
              if (inviteCode != null)
                Padding(
                  padding: const EdgeInsets.only(top: ThemeSizes.md),
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: inviteCode));
                      showSnackBar(
                        'Codice invito copiato negli appunti!',
                        color: ColorPalette.success,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.sm,
                        vertical: ThemeSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: context.secondaryBgColor,
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share,
                            size: 16,
                            color: context.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Codice Invito:',
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  context.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  ThemeSizes.borderRadiusSm),
                              border: Border.all(
                                  color: context.primaryColor
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              inviteCode,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.copy,
                            size: 14,
                            color: context.textSecondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
