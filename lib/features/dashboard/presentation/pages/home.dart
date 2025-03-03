// homepage.dart
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/pages/challenge.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/article_card.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/divider.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/page_redirection_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static get route => MaterialPageRoute(builder: (context) => const HomePage());
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: CustomDivider(
            text: "Inizia Ora",
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PageRedirectionCard(
              title: "Crea Lega",
              icon: Icons.add_circle_outline_sharp,
              onPressed: () {},
            ),
            const SizedBox(width: 20),
            PageRedirectionCard(
              title: "Cerca Lega",
              icon: Icons.search_rounded,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: CustomDivider(
            text: 'I Nostri Articoli',
          ),
        ),
        _Articles()
      ],
    );
  }
}

class _Articles extends StatelessWidget {
  const _Articles();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ArticleCard(
          imagePath: 'assets/images/baddie-bg.jpg',
          title: 'Rimorchiare come un pro in vacanza',
          readingTime: '2 min',
          redirectPage: ChallengePage(),
        ),
        ArticleCard(
          imagePath: 'assets/images/social-enhance-bg.jpg',
          title: 'Come vivere una vacanza indimenticabile',
          readingTime: '2 min',
          redirectPage: ChallengePage(),
        ),
      ],
    );
  }
}
