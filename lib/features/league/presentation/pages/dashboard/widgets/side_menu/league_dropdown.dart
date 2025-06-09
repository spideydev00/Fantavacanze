import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class LeagueDropdown extends StatelessWidget {
  const LeagueDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
        builder: (context, appLeagueState) {
      // Mostra il dropdown solo quando esistono delle leghe
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
            const CustomDivider(text: "Le Mie Leghe"),
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
    // Controllo di sicurezza: verifica che l'ID della lega selezionata esista nella lista
    final leagueIds = leagues.map((l) => l.id).toList();
    final safeValue = leagueIds.contains(selectedLeague.id)
        ? selectedLeague.id
        : (leagueIds.isNotEmpty ? leagueIds.first : null);

    // Se non viene trovato nessun valore valido, mostra un placeholder
    if (safeValue == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.md,
          vertical: ThemeSizes.sm,
        ),
        decoration: BoxDecoration(
          color: context.bgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        ),
        child: Text(
          "Nessuna lega disponibile",
          style: context.textTheme.bodyMedium,
        ),
      );
    }

    // Implementazione con DropdownButton2
    return DropdownButton2<String>(
      value: safeValue,
      onChanged: (String? newLeagueId) {
        if (newLeagueId != null) {
          final newLeague = leagues.firstWhere(
            (league) => league.id == newLeagueId,
          );
          context.read<AppLeagueCubit>().selectLeague(newLeague);
        }
      },

      // `items` definisce l'aspetto degli elementi nel menu APERTO.
      items: leagues.map<DropdownMenuItem<String>>((League league) {
        return DropdownMenuItem<String>(
          value: league.id,
          child: Row(
            children: [
              Icon(
                Icons.group,
                size: 22,
                color: context.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Expanded(
                child: Text(
                  league.name,
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),

      // `selectedItemBuilder` ora costruisce un widget con icona e testo
      // anche quando il dropdown è chiuso.
      selectedItemBuilder: (context) {
        return leagues.map<Widget>((League league) {
          return Row(
            children: [
              Icon(
                Icons.group,
                size: 22,
                color: context.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Expanded(
                child: Text(
                  league.name,
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  // *** MODIFICA CHIAVE ***
                  // Permette al testo di andare a capo su un massimo di 2 righe.
                  maxLines: 2,
                ),
              ),
            ],
          );
        }).toList();
      },

      isExpanded: true,
      underline: const SizedBox(),

      // Stile del bottone con il nuovo bordo
      buttonStyleData: ButtonStyleData(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.md,
          vertical: ThemeSizes.xs,
        ),
        decoration: BoxDecoration(
          color: context.bgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          border: Border.all(
            color: ColorPalette.darkGrey,
            width: 0.2,
          ),
        ),
      ),

      // Stile dell'icona a freccia
      iconStyleData: IconStyleData(
        icon: const Icon(Icons.arrow_drop_down),
        iconEnabledColor: context.textTheme.bodyMedium?.color,
      ),

      // Stile del menu a tendina
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          color: context.bgColor,
        ),
        offset: const Offset(0, -5),
      ),

      // Stile per gli elementi nel menu
      menuItemStyleData: const MenuItemStyleData(
        height: 40,
        padding: EdgeInsets.only(left: 14, right: 14),
      ),
    );
  }
}
