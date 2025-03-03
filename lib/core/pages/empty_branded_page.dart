import 'dart:async';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class EmptyBrandedPage extends StatefulWidget {
  final String? bgImagePath;
  final String logoImagePath;
  final double logoTopMargin;
  final MainAxisAlignment mainColumnAlignment;
  final bool isBackNavigationActive;
  final List<Widget> widgets;
  final List<Widget>? newColumnWidgets;
  final Widget? leading;
  final double leadingTop;
  final double leadingLeft;
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
    this.logoTopMargin = 30,
    this.leading,
    this.leadingTop = 85,
    this.leadingLeft = 30,
    this.bottomNavBar,
    this.floatingButton,
  });

  // Versione senza immagine di sfondo
  const EmptyBrandedPage.withoutImage({
    super.key,
    required this.logoImagePath,
    this.isBackNavigationActive = false,
    required this.mainColumnAlignment,
    required this.widgets,
    this.newColumnWidgets,
    this.logoTopMargin = 30,
    this.leading,
    this.leadingTop = 85,
    this.leadingLeft = 30,
    this.bottomNavBar,
    this.floatingButton,
  }) : bgImagePath = null;

  @override
  State<EmptyBrandedPage> createState() => _EmptyBrandedPageState();
}

class _EmptyBrandedPageState extends State<EmptyBrandedPage> {
  bool _isLeadingVisible = true;
  bool _isScrolling = false;
  Timer? _scrollTimer;

  @override
  Widget build(BuildContext context) {
    Widget scaffold = Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: widget.isBackNavigationActive,
        forceMaterialTransparency: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor:
          widget.bgImagePath != null ? Colors.transparent : ColorPalette.darkBg,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: widget.mainColumnAlignment,
            children: [
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollUpdateNotification) {
                      setState(() {
                        _isLeadingVisible = false;
                        _isScrolling = true;
                      });

                      _scrollTimer?.cancel();
                      _scrollTimer =
                          Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          _isLeadingVisible = true;
                          _isScrolling = false;
                        });
                      });
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: widget.logoTopMargin),
                        Image.asset(
                          widget.logoImagePath,
                          width: Constants.getWidth(context) * 0.5,
                        ),
                        const SizedBox(height: 5),
                        ...widget.widgets,
                      ],
                    ),
                  ),
                ),
              ),
              if ((widget.mainColumnAlignment ==
                          MainAxisAlignment.spaceBetween ||
                      widget.mainColumnAlignment ==
                          MainAxisAlignment.spaceEvenly ||
                      widget.mainColumnAlignment ==
                          MainAxisAlignment.spaceAround) &&
                  widget.newColumnWidgets != null)
                Column(children: [...widget.newColumnWidgets!]),
            ],
          ),

          // Il leading animato quando si scorre
          if (widget.leading != null)
            Positioned(
              top: widget.leadingTop,
              left: widget.leadingLeft,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isLeadingVisible ? 1.0 : 0.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    color: _isScrolling
                        ? Colors.transparent
                        : ColorPalette.secondaryBg,
                    borderRadius: BorderRadius.circular(ThemeSizes.xl),
                  ),
                  child: GestureDetector(
                    child: widget.leading!,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: widget.bottomNavBar,
      floatingActionButton: widget.floatingButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

    return widget.bgImagePath != null
        ? Container(
            constraints: const BoxConstraints.expand(),
            child: DecoratedBox(
              position: DecorationPosition.background,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.bgImagePath!),
                  fit: BoxFit.cover,
                ),
              ),
              child: scaffold,
            ),
          )
        : scaffold;
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }
}
