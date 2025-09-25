import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/fs_main_page.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_onboarding/fs_onboarding_page_content.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FsOnboardingScreen extends StatefulWidget {
  static const String routeName = '/fs-onboarding';

  static get route => MaterialPageRoute(
        builder: (context) => const FsOnboardingScreen(),
        settings: const RouteSettings(name: routeName),
      );

  const FsOnboardingScreen({super.key});

  @override
  State<FsOnboardingScreen> createState() => _FsOnboardingScreenState();
}

class _FsOnboardingScreenState extends State<FsOnboardingScreen> {
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
        return "assets/images/fantaserata/images/onboarding/1.png";
      case 1:
        return "assets/images/fantaserata/images/onboarding/2.png";
      case 2:
        return "assets/images/fantaserata/images/onboarding/3.png";
      case 3:
        return "assets/images/fantaserata/images/onboarding/4.png";
      case 4:
        return "assets/images/fantaserata/images/onboarding/5.png";
      case 5:
        return "assets/images/fantaserata/images/onboarding/6.png";
      default:
        return "assets/images/fantaserata/images/onboarding/1.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/fantaserata/logo/Logo-Fs.png",
                width: Constants.getWidth(context) * 0.40,
              ),
              SizedBox(width: 50),
            ],
          ),
        ),
        toolbarHeight: 150,
      ),
      body: Stack(
        children: [
          // Background with animation
          AnimatedBuilder(
            animation: controller,
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
                  onLastPage = (index == 5);
                },
              )
            },
            children: [
              FsOnboardingPageContent(
                title: "Sfida gli amici o le amiche in serata.",
                subtitle:
                    "Il FantaSerata è studiato per le singole serate, per vivere al massimo ogni singolo momento della vostra vita!",
                alignment: MainAxisAlignment.start,
                ySpace: Constants.getHeight(context) * 0.2,
              ),
              FsOnboardingPageContent(
                title: "Durata limitata.",
                subtitle:
                    "Alle 7 del mattino seguente la lega si autodistruggerà, chi riuscirà a completare più obiettivi in tempo?",
                ySpace: Constants.getHeight(context) * 0.25,
              ),
              FsOnboardingPageContent(
                title: "Gli obiettivi \"fissi\".",
                subtitle:
                    "Ogni partecipante avrà, in base al sesso e alla situazione sentimentale (single o meno) 3 obiettivi FISSI tarati per ogni singola situazione!",
                alignment: MainAxisAlignment.start,
                ySpace: Constants.getHeight(context) * 0.25,
              ),
              FsOnboardingPageContent(
                title: "Gli obiettivi \"unici\"",
                subtitle:
                    "Ogni partecipante avrà 2 obiettivi UNICI che potrà decidere di completare ed essere incoronato re o regina della serata.",
                ySpace: Constants.getHeight(context) * 0.30,
              ),
              FsOnboardingPageContent(
                title: "Gli obiettivi \"extra\"",
                subtitle:
                    "Hai fatto qualcosa che ritieni meritevole di punti extra? BENE, potrai chiedere all'amministratore della lega (il creatore) di aggiungerti i punti in questione!",
                alignment: MainAxisAlignment.start,
                ySpace: Constants.getHeight(context) * 0.18,
              ),
              FsOnboardingPageContent(
                title: "Che aspetti?",
                subtitle:
                    "Sei pronto ad immergerti in un'esperienza di gaming \"sociale\" nuova e rivoluzionaria? LET'S GOOOOO!",
                ySpace: Constants.getHeight(context) * 0.33,
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
                    controller.jumpToPage(5);
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
                  count: 6,
                  effect: WormEffect(
                    activeDotColor: ColorPalette.primary(ThemeMode.dark),
                    dotColor: ColorPalette.white.withValues(alpha: 0.8),
                  ),
                ),

                onLastPage
                    //done
                    ? GestureDetector(
                        onTap: () {
                          // TODO: Add logic to mark hasPlayedFs as true and navigate
                          Navigator.of(context)
                              .pushReplacement(FsMainPage.route);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(ThemeSizes.md),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                            color: ColorPalette.success.withValues(alpha: 0.7),
                          ),
                          child: Text(
                            "Iniziamo!",
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
    );
  }
}
