import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:flutter/material.dart';

class EmptyBrandedPage extends StatelessWidget {
  final String bgImagePath;
  final MainAxisAlignment mainColumnAlignment;
  final bool isBackNavigationActive;
  final List<Widget> widgets;
  final List<Widget>? newColumnWidgets;
  final Widget? leading;

  const EmptyBrandedPage({
    super.key,
    required this.bgImagePath,
    this.isBackNavigationActive = false,
    required this.mainColumnAlignment,
    required this.widgets,
    this.newColumnWidgets,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    //conditions
    // ignore: no_leading_underscores_for_local_identifiers
    final bool _conditions =
        (mainColumnAlignment == MainAxisAlignment.spaceBetween ||
            mainColumnAlignment == MainAxisAlignment.spaceEvenly ||
            mainColumnAlignment == MainAxisAlignment.spaceAround);

    return Container(
      constraints: const BoxConstraints.expand(),
      child: DecoratedBox(
        position: DecorationPosition.background,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            automaticallyImplyLeading: isBackNavigationActive,
            forceMaterialTransparency: true,
            leading: leading,
          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: mainColumnAlignment,
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Image.asset(
                        'images/logo-neon.png',
                        width: Constants.getWidth(context) * 0.5,
                      ),
                      const SizedBox(height: 5),
                      ...widgets
                    ],
                  ),
                ),
              ),
              //Only use widgets with a space between, around or evenly
              _conditions && newColumnWidgets != null
                  ? Column(
                      children: [...newColumnWidgets!],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
