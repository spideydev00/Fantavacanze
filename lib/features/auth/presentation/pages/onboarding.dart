import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/on_boarding_page.dart';
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Image.asset(
          "images/logo-neon.png",
          width: Constants.getWidth(context) * 0.30,
        ),
        toolbarHeight: 150,
      ),
      body: Stack(
        children: [
          //page view
          PageView(
            controller: controller,
            onPageChanged: (index) => {
              setState(() {
                onLastPage = (index == 2);
              })
            },
            children: const [
              OnBoardingPage(
                pageDescription: "Dai una spinta alle tue vacanze",
                imagePath: "images/summer-holiday-icon.png",
              ),
              OnBoardingPage(
                pageDescription: "Sfida i tuoi amici",
                imagePath: "images/angry-heart.png",
              ),
              OnBoardingPage(
                pageDescription: "Prova i nostri giochi",
                imagePath: "images/games-icon.png",
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
