import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/gender_selection_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/on_boarding_page_content.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';

  static get route => MaterialPageRoute(
        builder: (context) => const OnBoardingScreen(),
        settings: const RouteSettings(name: routeName),
      );
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  //keeps track of which page we're on
  PageController controller = PageController();
  bool onLastPage = false;
  int pageIndex = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String _getBackgroundImage(int index) {
    switch (index) {
      case 0:
        return "assets/images/baddie-bg.jpg";
      case 1:
        return "assets/images/social-enhance-bg.jpg";
      case 2:
        return "assets/images/emotions-bg.jpg";
      default:
        return "assets/images/baddie-bg.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Ascolta l'aggiornamento di isOnboarded e naviga di conseguenza
        if (state is AuthSuccess) {
          final user = state.loggedUser;

          if (user.gender == null) {
            Navigator.of(context).pushAndRemoveUntil(
              GenderSelectionPage.route,
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              DashboardScreen.route,
              (route) => false,
            );
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(ThemeSizes.lg),
            child: Center(
              child: Image.asset(
                pageIndex == 2
                    ? "assets/images/logo-dark.png"
                    : "assets/images/logo.png",
                width: Constants.getWidth(context) * 0.30,
              ),
            ),
          ),
          toolbarHeight: 150,
        ),
        body: Stack(
          children: [
            // Background with animation
            AnimatedBuilder(
              //listener (the controller, since it's updated on each scroll)
              animation: controller,
              //builder
              builder: (context, child) {
                return AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: Container(
                    key: ValueKey<int>(pageIndex),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_getBackgroundImage(pageIndex)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Page view
            PageView(
              controller: controller,
              onPageChanged: (index) => {
                setState(
                  () {
                    pageIndex = index;
                    onLastPage = (index == 2);
                  },
                )
              },
              children: [
                OnBoardingPageContent(
                  title: "Sfida Gli Amici.",
                  description:
                      "Partecipa a delle leghe con il tuo gruppo di amici per decretare il king o la baddie dell'estate!",
                  ySpace: Constants.getHeight(context) * 0.35,
                ),
                OnBoardingPageContent(
                  title: "Conosci Persone.",
                  description:
                      "Costruisci nuovi rapporti e rafforza le tue relazioni. Buttati, non avere paura di rischiare. YOLO!",
                  alignment: MainAxisAlignment.start,
                  ySpace: Constants.getHeight(context) * 0.17,
                ),
                const OnBoardingPageContent(
                  title: "Vivi Momenti Unici.",
                  description:
                      "Crea ricordi indimenticabili di cui poter discutere a distanza di anni. Goditi gli anni più belli.",
                ),
              ],
            ),
            Container(
              alignment: const Alignment(0, 0.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //skip
                  GestureDetector(
                    onTap: () {
                      controller.jumpToPage(2);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(ThemeSizes.md),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusLg),
                        color: ColorPalette.accent(ThemeMode.dark)
                            .withValues(alpha: 0.8),
                      ),
                      child: Text(
                        "Salta",
                        style: TextStyle(
                          color: ColorPalette.textPrimary(
                            ThemeMode.dark,
                          ).withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ),

                  //dot indicators
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: WormEffect(
                        activeDotColor: ColorPalette.primary(ThemeMode.dark),
                        dotColor: ColorPalette.white.withValues(alpha: 0.8)),
                  ),

                  onLastPage
                      //done
                      ? GestureDetector(
                          onTap: () {
                            // Invia solo l'evento e lascia che il BlocListener gestisca la navigazione
                            context.read<AuthBloc>().add(
                                  AuthChangeIsOnboardedValue(isOnboarded: true),
                                );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(ThemeSizes.md),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ThemeSizes.borderRadiusLg),
                              color:
                                  ColorPalette.success.withValues(alpha: 0.7),
                            ),
                            child: Text(
                              "Fatto",
                              style: TextStyle(
                                color: ColorPalette.textPrimary(
                                  ThemeMode.dark,
                                ).withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        )
                      //next
                      : GestureDetector(
                          onTap: () {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(ThemeSizes.md),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ThemeSizes.borderRadiusLg),
                              color: ColorPalette.accent(ThemeMode.dark)
                                  .withValues(alpha: 0.8),
                            ),
                            child: Text(
                              "Avanti",
                              style: TextStyle(
                                color: ColorPalette.textPrimary(
                                  ThemeMode.dark,
                                ).withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
