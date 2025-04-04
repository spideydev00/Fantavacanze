import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/homepage/article_card.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/divider.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/helpers/homepage/page_redirection_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
            child: CustomDivider(text: "Per Iniziare"),
          ),
          const SizedBox(height: 25),
          _buildActionButtons(context),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
            child: CustomDivider(text: 'I Nostri Articoli'),
          ),
          _buildArticles(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
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
    );
  }
}

Widget _buildArticles() {
  return Column(
    children: [
      ArticleCard(
        imagePath: 'assets/images/baddie-bg.jpg',
        title: 'Rimorchiare come un pro in vacanza',
        readingTime: '2 min',
        redirectPage: const HomePage(),
      ),
      ArticleCard(
        imagePath: 'assets/images/social-enhance-bg.jpg',
        title: 'Come vivere una vacanza indimenticabile',
        readingTime: '2 min',
        redirectPage: const HomePage(),
      ),
    ],
  );
}
