import 'package:flutter/material.dart';

@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  final Color primary;
  final Color accent;
  final bool hasPartner;

  const BrandColors({
    required this.primary,
    required this.accent,
    required this.hasPartner,
  });

  @override
  BrandColors copyWith({Color? primary, Color? accent, bool? hasPartner}) {
    return BrandColors(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      hasPartner: hasPartner ?? this.hasPartner,
    );
  }

  @override
  BrandColors lerp(BrandColors? other, double t) {
    if (other == null) {
      return this;
    }

    return BrandColors(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      hasPartner: t < 0.5 ? hasPartner : other.hasPartner,
    );
  }
}
