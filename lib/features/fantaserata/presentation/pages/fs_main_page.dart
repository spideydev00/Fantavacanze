import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_league_bloc/fs_bloc.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/navigation/create_fs_league/create_fs_league_page.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_hero_card.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_search_card.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_info_banner.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final AppUserCubit appUserCubit = context.read<AppUserCubit>();

    final String userId = appUserCubit.state is AppUserIsLoggedIn
        ? (appUserCubit.state as AppUserIsLoggedIn).user.id
        : '';

    final String userName = appUserCubit.state is AppUserIsLoggedIn
        ? (appUserCubit.state as AppUserIsLoggedIn).user.name
        : '';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        title: BlocBuilder<AppThemeCubit, AppThemeState>(
          builder: (context, state) {
            if (state.themeMode == ThemeMode.dark) {
              return Image.asset(
                'assets/images/fantaserata/logo/FantaSerata-esteso-neon.png',
                width: Constants.getWidth(context) * 0.65,
              );
            }
            return Image.asset(
              'assets/images/fantaserata/logo/fantaserata-no-neon-logo.png',
              width: Constants.getWidth(context) * 0.65,
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            DashboardScreen.route,
            (route) => false,
          ),
        ),
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
                context.read<FsBloc>().add(
                      JoinFsLeagueEvent(
                        inviteCode: _inviteCodeController.text,
                        userId: userId,
                        userName: userName,
                      ),
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
