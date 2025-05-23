import 'package:fantavacanze_official/features/blog/presentation/widgets/article_card.dart';
import 'package:flutter/material.dart';

class ArticlesList extends StatelessWidget {
  final List<ArticleData> articles;
  final Widget? emptyWidget;

  const ArticlesList({
    super.key,
    required this.articles,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }

    return Column(
      children: articles
          .map((article) => ArticleCard(
                imagePath: article.imagePath,
                title: article.title,
                readingTime: article.readingTime,
                redirectPage: article.redirectPage,
              ))
          .toList(),
    );
  }
}

class ArticleData {
  final String imagePath;
  final String title;
  final String readingTime;
  final Widget redirectPage;

  const ArticleData({
    required this.imagePath,
    required this.title,
    required this.readingTime,
    required this.redirectPage,
  });
}
