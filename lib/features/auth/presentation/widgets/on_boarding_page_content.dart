import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/promo_text.dart';
import 'package:flutter/material.dart';

class OnBoardingPageContent extends StatelessWidget {
  const OnBoardingPageContent({
    super.key,
    required this.title,
    required this.description,
    this.ySpace = 0,
    this.alignment = MainAxisAlignment.center,
  });

  final String title;
  final String description;
  final double ySpace;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeSizes.xxl),
      child: Column(
        mainAxisAlignment: alignment,
        children: [
          SizedBox(height: ySpace),
          PromoText(text: title),
          const SizedBox(height: 5),
          Text(
            description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
