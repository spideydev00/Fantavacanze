import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';

class EmptyBrandedPage extends StatelessWidget {
  final String? bgImagePath;
  final String logoImagePath;
  final MainAxisAlignment mainColumnAlignment;
  final bool isBackNavigationActive;
  final List<Widget> widgets;
  final List<Widget>? newColumnWidgets;
  final Widget? leading;
  final Widget? bottomNavBar;
  final Widget? floatingButton;

  const EmptyBrandedPage({
    super.key,
    required this.logoImagePath,
    required this.bgImagePath,
    this.isBackNavigationActive = false,
    required this.mainColumnAlignment,
    required this.widgets,
    this.newColumnWidgets,
    this.leading,
    this.bottomNavBar,
    this.floatingButton,
  });

  /// Named constructor for a version without a background image
  const EmptyBrandedPage.withoutImage({
    super.key,
    required this.logoImagePath,
    this.isBackNavigationActive = false,
    required this.mainColumnAlignment,
    required this.widgets,
    this.newColumnWidgets,
    this.leading,
    this.bottomNavBar,
    this.floatingButton,
  }) : bgImagePath = null;

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final bool _conditions =
        (mainColumnAlignment == MainAxisAlignment.spaceBetween ||
            mainColumnAlignment == MainAxisAlignment.spaceEvenly ||
            mainColumnAlignment == MainAxisAlignment.spaceAround);

    Widget scaffold = Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: isBackNavigationActive,
        forceMaterialTransparency: true,
        leading: leading,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor:
          bgImagePath != null ? Colors.transparent : ColorPalette.darkBg,
      body: Column(
        mainAxisAlignment: mainColumnAlignment,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    logoImagePath,
                    width: Constants.getWidth(context) * 0.5,
                  ),
                  const SizedBox(height: 5),
                  ...widgets
                ],
              ),
            ),
          ),
          if (_conditions && newColumnWidgets != null)
            Column(children: [...newColumnWidgets!]),
        ],
      ),
      bottomNavigationBar: bottomNavBar,
      floatingActionButton: floatingButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

    return bgImagePath != null
        ? Container(
            constraints: const BoxConstraints.expand(),
            child: DecoratedBox(
              position: DecorationPosition.background,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(bgImagePath!),
                  fit: BoxFit.cover,
                ),
              ),
              child: scaffold,
            ),
          )
        : scaffold;
  }
}
