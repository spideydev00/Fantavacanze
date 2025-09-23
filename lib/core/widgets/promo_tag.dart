import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

class PromoTag extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const PromoTag({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.padding,
    this.borderRadius,
  });

  /// Factory constructor for "Novità" tag with default red styling
  factory PromoTag.novita() {
    return const PromoTag(
      text: "Novità",
      backgroundColor: ColorPalette.error,
      textColor: Colors.white,
      fontSize: 10,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
  }

  /// Factory constructor for "Premium" tag with golden styling
  factory PromoTag.premium() {
    return const PromoTag(
      text: "Premium",
      backgroundColor: ColorPalette.premiumUser,
      textColor: Colors.white,
      fontSize: 10,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
  }

  /// Factory constructor for "Nuovo" tag with info styling
  factory PromoTag.nuovo() {
    return const PromoTag(
      text: "Nuovo",
      backgroundColor: ColorPalette.info,
      textColor: Colors.white,
      fontSize: 10,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? ColorPalette.error,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                (backgroundColor ?? ColorPalette.error).withValues(alpha: 0.3),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}
