import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/create_fs_league_page.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_hero_card.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_search_card.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_info_banner.dart';
import 'package:flutter/material.dart';

class FsMainPage extends StatefulWidget {
  static const String routeName = '/fs-main';

  static get route => MaterialPageRoute(
        builder: (context) => const FsMainPage(),
        settings: const RouteSettings(name: routeName),
      );

  const FsMainPage({super.key});

  @override
  State<FsMainPage> createState() => _FsMainPageState();
}

class _FsMainPageState extends State<FsMainPage> {
  final _inviteCodeController = TextEditingController();

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        title: Image.asset(
          'assets/images/fantaserata/logo/Logo-Fs.png',
          width: Constants.getWidth(context) * 0.30,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero section
            FsHeroCard(
              title: 'Crea Una Nuova Lega!',
              subtitle:
                  'Crea una nuova Fantaserata e sfida il tuo gruppo. Chi la porterà a casa?!',
              icon: Icons.flash_on_rounded,
              onTap: () {
                Navigator.of(context).push(CreateFsLeaguePage.route);
              },
            ),

            SizedBox(height: ThemeSizes.xl),

            // Divider
            CustomDivider(
              text: 'Oppure cerca una lega esistente',
              color: context.textPrimaryColor.withValues(alpha: 0.6),
            ),

            const SizedBox(height: ThemeSizes.lg),

            // Join League Section
            FsSearchCard(
              title: 'Hai ricevuto un codice invito?',
              hintText: 'Inserisci il codice qui',
              controller: _inviteCodeController,
              onSearch: () {
                // TODO: Implement join league logic via BLoC
                showSpecificSnackBar(
                  context,
                  'Ricerca lega in corso...',
                  color: ColorPalette.info,
                );
              },
            ),

            const SizedBox(height: ThemeSizes.xl),

            // Info Banner
            FsInfoBanner(
              title: 'Ricorda...',
              message:
                  'Le leghe FantaSerata si autodistruggono alle 7:00 del mattino seguente.',
              icon: Icons.timer_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
