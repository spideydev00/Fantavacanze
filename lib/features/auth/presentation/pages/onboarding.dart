import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/on_boarding_page_content.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/promo_text.dart';
import 'package:fantavacanze_official/home.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  static get route =>
      MaterialPageRoute(builder: (context) => const OnBoardingScreen());
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
        return "images/baddie-bg.jpg";
      case 1:
        return "images/social-enhance-bg.jpg";
      case 2:
        return "images/emotions-bg.jpg";
      default:
        return "images/baddie-bg.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Image.asset(
          "images/logo-high-padding.png",
          width: Constants.getWidth(context) * 0.60,
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
                ySpace: Constants.getHeight(context) * 0.4,
              ),
              Stack(
                children: [
                  // Promo Text at the top
                  Positioned(
                    top: Constants.getHeight(context) * 0.17,
                    left: 0,
                    right: 0,
                    child: const PromoText(text: "Conosci Persone."),
                  ),

                  // Descriptive Text below
                  Positioned(
                    top: Constants.getHeight(context) * 0.17 +
                        100 +
                        16, // Adjust placement
                    left: ThemeSizes.xxl,
                    right: ThemeSizes.xxl,
                    child: const Text(
                      "Costruisci nuovi rapporti e rafforza le tue relazioni. Buttati, non avere paura di rischiare. YOLO!",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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
                  child: const Text("Skip"),
                ),

                //dot indicators
                SmoothPageIndicator(controller: controller, count: 3),

                onLastPage
                    //done
                    ? GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              HomePage.route, (route) => false);
                        },
                        child: const Text("Done"),
                      )
                    //next
                    : GestureDetector(
                        onTap: () {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: const Text("Next"),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
