import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:flutter/material.dart';

class FsInfoSection extends StatelessWidget {
  const FsInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoContainer(
          title: 'Come invitare i tuoi amici',
          message:
              'Condividi il codice invito con i tuoi amici. Potranno usarlo per partecipare alla tua lega FantaSerata!',
          icon: Icons.people_alt_rounded,
          color: ColorPalette.info,
        ),
        const SizedBox(height: ThemeSizes.md),
        InfoContainer(
          title: '⏰ Durata limitata',
          message:
              'Ricorda: la tua lega si autodistruggerà alle 7:00 del mattino seguente. Godetevi ogni momento!',
          icon: Icons.timer_outlined,
          color: context.primaryColor,
        ),
        const SizedBox(height: ThemeSizes.md),
        InfoContainer(
          title: '👑 Sei l\'Admin',
          message:
              'Come creatore della lega, puoi gestire eventi, assegnare punti bonus e controllare la classifica.',
          icon: Icons.admin_panel_settings_rounded,
          color: ColorPalette.success,
        ),
      ],
    );
  }
}
