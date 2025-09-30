import 'package:fantavacanze_official/core/theme/colors.dart';
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
              'Condividi il codice invito con i tuoi amici. Potranno usarlo per partecipare a questa FantaSerata!',
          icon: Icons.people_alt_rounded,
          color: ColorPalette.info,
        ),
      ],
    );
  }
}
