import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/seasonal_event/seasonal_event_cubit.dart';
import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
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
      body: BlocBuilder<SeasonalEventCubit, SeasonalEventState>(
        builder: (context, seasonalState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero section with seasonal title
                seasonalState.activeNightType != FsNightType.apresSki
                    ? FsHeroCard(
                        title: _getSeasonalCreateTitle(
                          seasonalState.activeNightType,
                        ),
                        subtitle: _getSeasonalCreateSubtitle(
                          seasonalState.activeNightType,
                        ),
                        svgIconPath: _getSeasonalIcon(
                          seasonalState.activeNightType,
                        ),
                        onTap: () => _navigateToCreateLeague(
                          seasonalState.activeNightType,
                        ),
                        gradients: context.seasonalGradient,
                      )
                    : Column(
                        children: [
                          FsHeroCard(
                            title: "FantaSerata Classica",
                            subtitle: 'Chi la porterà a casa?!',
                            onTap: () => _navigateToCreateLeague(
                              FsNightType.def,
                            ),
                            gradients: ColorPalette.fsGradients,
                            svgIconPath:
                                'assets/images/icons/homepage_icons/drink-games-page-icon.svg',
                          ),
                          SizedBox(
                            height: ThemeSizes.md,
                          ),
                          FsHeroCard(
                            title: "Fanta Après-Ski",
                            subtitle: 'Hai abbastanza ghiaccio nelle vene?',
                            onTap: () => _navigateToCreateLeague(
                              seasonalState.activeNightType,
                            ),
                            gradients: ColorPalette.winterGradient,
                            svgIconPath:
                                'assets/images/icons/fs_icons/fanta-ski-emoji.svg',
                          )
                        ],
                      ),

                SizedBox(height: ThemeSizes.xl),

                // Divider
                CustomDivider(
                  text: 'Oppure cerca una lega esistente',
                  color: context.textPrimaryColor.withValues(alpha: 0.6),
                ),

                const SizedBox(height: ThemeSizes.lg),

                // Join League Section with seasonal join logic
                FsSearchCard(
                  title: 'Hai ricevuto un codice invito?',
                  hintText: 'Inserisci il codice qui',
                  controller: _inviteCodeController,
                  onSearch: () => _handleJoinLeague(
                    seasonalState.activeNightType,
                    userId,
                    userName,
                  ),
                ),

                const SizedBox(height: ThemeSizes.xl),

                // Info Banner with seasonal message
                FsInfoBanner(
                  title: _getSeasonalInfoTitle(seasonalState.activeNightType),
                  message:
                      _getSeasonalInfoMessage(seasonalState.activeNightType),
                  svgIconPath:
                      _getSeasonalInfoIcon(seasonalState.activeNightType),
                  color: context.seasonalGradient[1],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Navigate to create league page or trigger seasonal creation
  void _navigateToCreateLeague(FsNightType nightType) {
    Navigator.of(context).push(
      CreateFsLeaguePage.route(nightType: nightType),
    );
  }

  /// Handle join league with seasonal logic
  void _handleJoinLeague(
      FsNightType nightType, String userId, String userName) {
    if (nightType == FsNightType.def) {
      // Regular join
      context.read<FsBloc>().add(
            JoinFsLeagueEvent(
              inviteCode: _inviteCodeController.text,
              userId: userId,
              userName: userName,
            ),
          );
    } else {
      // Night-specific join
      context.read<FsBloc>().add(
            JoinNightSpecificFsLeagueEvent(
              inviteCode: _inviteCodeController.text,
              userId: userId,
              userName: userName,
            ),
          );
    }
  }

  /// Get seasonal create title
  String _getSeasonalCreateTitle(FsNightType nightType) {
    switch (nightType) {
      case FsNightType.halloween:
        return 'Crea una Fanta Halloween!';
      case FsNightType.christmas:
        return 'Crea un Fanta Vigilia!';
      case FsNightType.carnival:
        return 'Crea un Fanta Carnevale!';
      case FsNightType.newYearsEve:
        return 'Crea un Fanta Capodanno!';
      case FsNightType.apresSki:
        return 'Crea un Fanta Après-Ski!';
      default:
        return 'Crea Una Nuova Lega!';
    }
  }

  /// Get seasonal create subtitle
  String _getSeasonalCreateSubtitle(FsNightType nightType) {
    switch (nightType) {
      case FsNightType.halloween:
        return 'Crea una serata da brivido! Chi la porterà a casa?!';
      case FsNightType.christmas:
        return 'Celebra il Natale con una serata magica! Chi la porterà a casa?!';
      case FsNightType.carnival:
        return 'Festeggia il Carnevale con una serata indimenticabile! Chi la porterà a casa?!';
      case FsNightType.newYearsEve:
        return 'Brinda al nuovo anno con una serata speciale! Chi la porterà a casa?!';
      case FsNightType.apresSki:
        return 'Goditi l\'après ski con una serata sulla neve! Chi la porterà a casa?!';
      default:
        return 'Crea una nuova Fantaserata e sfida il tuo gruppo. Chi la porterà a casa?!';
    }
  }

  /// Get seasonal icon
  String _getSeasonalIcon(FsNightType nightType) {
    switch (nightType) {
      case FsNightType.halloween:
        return 'assets/images/icons/fs_icons/fanta-halloween-emoji-2.svg';
      case FsNightType.christmas:
        return 'assets/images/icons/fs_icons/fanta-christmas-emoji.svg';
      case FsNightType.carnival:
        return 'assets/images/icons/fs_icons/fanta-carnival-emoji.svg';
      case FsNightType.newYearsEve:
        return 'assets/images/icons/fs_icons/fanta-newyear-emoji.svg';
      case FsNightType.apresSki:
        return 'assets/images/icons/fs_icons/fanta-ski-emoji.svg';
      default:
        return 'assets/images/icons/homepage_icons/drink-games-page-icon.svg';
    }
  }

  /// Get seasonal info title
  String _getSeasonalInfoTitle(FsNightType nightType) {
    switch (nightType) {
      case FsNightType.halloween:
        return 'Notte di Halloween!';
      case FsNightType.christmas:
        return 'Atmosfera Natalizia!';
      case FsNightType.carnival:
        return 'Spirito Carnevalesco!';
      case FsNightType.newYearsEve:
        return 'Notte di Capodanno!';
      case FsNightType.apresSki:
        return 'Stagione Invernale!';
      default:
        return 'Ricorda...';
    }
  }

  /// Get seasonal info message
  String _getSeasonalInfoMessage(FsNightType nightType) {
    switch (nightType) {
      case FsNightType.halloween:
        return 'Gli obiettivi sono più spaventosi del solito! Le leghe si autodistruggono alle 7:00.';
      case FsNightType.christmas:
        return 'Obiettivi speciali natalizi ti aspettano! Le leghe si autodistruggono alle 7:00.';
      case FsNightType.carnival:
        return 'Preparati per obiettivi colorati e divertenti! Le leghe si autodistruggono alle 7:00.';
      case FsNightType.newYearsEve:
        return 'Brinda con obiettivi esplosivi! Le leghe si autodistruggono alle 7:00.';
      case FsNightType.apresSki:
        return 'Obiettivi freddi come la neve! Le leghe si autodistruggono alle 7:00.';
      default:
        return 'Le leghe FantaSerata si autodistruggono alle 7:00 del mattino seguente.';
    }
  }

  /// Get seasonal info icon
  String _getSeasonalInfoIcon(FsNightType nightType) {
    switch (nightType) {
      case FsNightType.halloween:
        return 'assets/images/icons/fs_icons/fanta-halloween-emoji-2.svg';
      case FsNightType.christmas:
        return 'assets/images/icons/fs_icons/fanta-christmas-emoji.svg';
      case FsNightType.carnival:
        return 'assets/images/icons/fs_icons/fanta-carnival-emoji.svg';
      case FsNightType.newYearsEve:
        return 'assets/images/icons/fs_icons/fanta-newyear-emoji.svg';
      case FsNightType.apresSki:
        return 'assets/images/icons/fs_icons/fanta-ski-emoji.svg';
      default:
        return 'assets/images/icons/homepage_icons/thunder-icon.svg';
    }
  }
}
