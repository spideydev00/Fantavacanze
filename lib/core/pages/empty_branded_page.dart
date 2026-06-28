import 'dart:io';

import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:flutter/material.dart';

class EmptyBrandedPage extends StatefulWidget {
  final String? bgImagePath;
  final String logoImagePath;
  final double logoTopMargin;
  final MainAxisAlignment mainColumnAlignment;
  final bool isBackNavigationActive;
  final List<Widget> widgets;
  final List<Widget>? newColumnWidgets;

  /// Ombra/gradiente scuro opzionale ancorato in alto, per migliorare il
  /// contrasto del logo sopra immagini di sfondo chiare.
  final bool hasTopShadow;

  /// Altezza dell'ombra dall'alto. Default: 35% dell'altezza schermo.
  final double? topShadowHeight;

  const EmptyBrandedPage({
    super.key,
    required this.logoImagePath,
    required this.bgImagePath,
    this.isBackNavigationActive = false,
    required this.mainColumnAlignment,
    required this.widgets,
    this.newColumnWidgets,
    this.logoTopMargin = 30,
    this.hasTopShadow = false,
    this.topShadowHeight,
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
    this.hasTopShadow = false,
    this.topShadowHeight,
  }) : bgImagePath = null;

  @override
  State<EmptyBrandedPage> createState() => _EmptyBrandedPageState();
}

class _EmptyBrandedPageState extends State<EmptyBrandedPage> {
  @override
  Widget build(BuildContext context) {
    Widget scaffold = Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: widget.isBackNavigationActive
            ? const BackButton(color: Colors.white)
            : null,
        forceMaterialTransparency: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor:
          widget.bgImagePath != null ? Colors.transparent : context.bgColor,
      body: Stack(
        children: [
          if (widget.hasTopShadow)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height:
                  widget.topShadowHeight ?? Constants.getHeight(context) * 0.55,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x99000000),
                        Color(0x00000000),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisAlignment: widget.mainColumnAlignment,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: widget.logoTopMargin),
                        Padding(
                          padding: Platform.isIOS
                              ? EdgeInsets.symmetric(vertical: 30)
                              : EdgeInsets.symmetric(vertical: 10),
                          child: Image.asset(
                            widget.logoImagePath,
                            width: Constants.getWidth(context) * 0.40,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...widget.widgets,
                      ],
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
          ),
        ],
      ),
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
}
