import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeagueDropdown extends StatelessWidget {
  const LeagueDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
        builder: (context, appLeagueState) {
      // Only show dropdown when leagues exist
      if (appLeagueState is! AppLeagueExists) {
        return const SizedBox.shrink();
      }

      final leagues = appLeagueState.leagues;
      final selectedLeague = appLeagueState.selectedLeague;

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.md,
          vertical: ThemeSizes.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDivider(text: "Le Mie Leghe"),
            const SizedBox(height: ThemeSizes.xs),
            _buildLeagueSelector(
              context,
              leagues,
              selectedLeague,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLeagueSelector(
      BuildContext context, List<League> leagues, League selectedLeague) {
    // Safety check: Verify the selected league ID exists in the leagues list
    final leagueIds = leagues.map((l) => l.id).toList();
    final safeValue = leagueIds.contains(selectedLeague.id)
        ? selectedLeague.id
        : (leagueIds.isNotEmpty ? leagueIds.first : null);

    // If no valid value can be found, show a placeholder instead of dropdown
    if (safeValue == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.md,
          vertical: ThemeSizes.sm,
        ),
        decoration: BoxDecoration(
          color: context.bgColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          border: Border.all(
            color: context.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          "Nessuna lega disponibile",
          style: context.textTheme.bodyMedium,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.md,
        vertical: ThemeSizes.xs,
      ),
      decoration: BoxDecoration(
        color: context.bgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        border: Border.all(
          color: context.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: safeValue,
        onChanged: (String? newLeagueId) {
          if (newLeagueId != null) {
            final newLeague = leagues.firstWhere(
              (league) => league.id == newLeagueId,
            );

            context.read<AppLeagueCubit>().selectLeague(newLeague);

            // Force dropdown to close to trigger UI refresh
            FocusScope.of(context).requestFocus(FocusNode());
          }
        },
        items: leagues.map<DropdownMenuItem<String>>((League league) {
          return DropdownMenuItem<String>(
            value: league.id,
            child: Text(
              league.name,
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: context.primaryColor,
        ),
        underline: const SizedBox(),
        style: context.textTheme.bodyMedium,
        dropdownColor: context.secondaryBgColor,
      ),
    );
  }
}
