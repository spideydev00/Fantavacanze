import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';

/// A customizable tab bar with custom indicator
///
/// This component displays a tab bar with custom indicator colors
/// for a more attractive UI than the standard TabBar.
class CustomTabBar extends StatelessWidget {
  /// The tab controller
  final TabController controller;

  /// The tab widgets to display
  final List<Widget> tabs;

  /// The colors for the indicator (one per tab)
  final List<Color> indicatorColors;

  /// Optional indicator weight
  final double indicatorWeight;

  /// Optional indicator size
  final TabBarIndicatorSize indicatorSize;

  /// Optional text styles
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  /// Optional background color (defaults to context.secondaryBgColor)
  final Color? backgroundColor;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    required this.indicatorColors,
    this.indicatorWeight = 3,
    this.indicatorSize = TabBarIndicatorSize.tab,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? context.secondaryBgColor,
      child: TabBar(
        controller: controller,
        tabs: tabs,
        indicatorWeight: indicatorWeight,
        indicatorSize: indicatorSize,
        dividerHeight: 0,
        labelStyle: labelStyle ?? const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: unselectedLabelStyle ??
            const TextStyle(fontWeight: FontWeight.normal),
        indicator: _CustomTabIndicator(
          controller: controller,
          colors: indicatorColors,
        ),
      ),
    );
  }
}

/// Custom tab indicator that changes color based on the selected tab
class _CustomTabIndicator extends Decoration {
  final TabController controller;
  final List<Color> colors;

  const _CustomTabIndicator({
    required this.controller,
    required this.colors,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomIndicatorPainter(
      controller: controller,
      colors: colors,
      onChanged: onChanged,
    );
  }
}

/// Painter for the custom tab indicator
class _CustomIndicatorPainter extends BoxPainter {
  final TabController controller;
  final List<Color> colors;

  _CustomIndicatorPainter({
    required this.controller,
    required this.colors,
    VoidCallback? onChanged,
  }) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    // Use the color corresponding to the current tab index
    final Color indicatorColor = colors[controller.index];

    final Paint paint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0;

    final double width = configuration.size!.width;
    final double height = 3.0; // indicator height
    final double left = offset.dx;
    final double top = offset.dy + configuration.size!.height - height;

    canvas.drawRect(Rect.fromLTWH(left, top, width, height), paint);
  }
}
