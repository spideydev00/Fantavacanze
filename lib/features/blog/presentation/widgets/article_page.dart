import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/dates-and-numbers/reading_time.dart';
import 'package:flutter/material.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.author,
    required this.publishDate,
    required this.content,
  });

  final String imagePath;
  final String title;
  final String author;
  final String publishDate;
  final String content;

  @override
  Widget build(BuildContext context) {
    final readingTime = getReadingTime(content);

    return Scaffold(
      // Usiamo CustomScrollView per avere più controllo sugli elementi,
      // in particolare sulla AppBar che si comprime (SliverAppBar).
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned:
                true, // Mantiene la AppBar visibile in alto quando compressa
            expandedHeight: 300.0, // Altezza dell'immagine quando espansa
            backgroundColor: context.bgColor, // Sfondo AppBar compressa
            leading: IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                // Il tag DEVE essere lo stesso usato nella ArticleCard
                tag: 'article_image_$imagePath',
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Aggiungiamo una sfumatura per migliorare la leggibilità
                  // del testo dell'AppBar quando l'immagine è scura.
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Qui inizia il contenuto testuale della pagina
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(ThemeSizes.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITOLO
                  Text(
                    title,
                    style: context.textTheme.displaySmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.md),

                  // METADATI: Autore, Data e Tempo di lettura
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 16, color: ColorPalette.darkGrey),
                      const SizedBox(width: ThemeSizes.xs),
                      Text(author, style: context.textTheme.labelMedium),
                      const SizedBox(width: ThemeSizes.lg),
                      Icon(Icons.calendar_today_outlined,
                          size: 14, color: ColorPalette.darkGrey),
                      const SizedBox(width: ThemeSizes.xs),
                      Text(publishDate, style: context.textTheme.labelMedium),
                    ],
                  ),
                  const SizedBox(height: ThemeSizes.sm),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 14, color: ColorPalette.darkGrey),
                      const SizedBox(width: ThemeSizes.xs),
                      Text(
                        '$readingTime min.',
                        style: context.textTheme.labelMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: ThemeSizes.lg),
                  const Divider(),
                  const SizedBox(height: ThemeSizes.lg),

                  // CONTENUTO DELL'ARTICOLO - Versione migliorata con formattazione
                  _buildStyledContent(context, content),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget per il contenuto stilizzato
  Widget _buildStyledContent(BuildContext context, String content) {
    if (content.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Contenuto in arrivo...'),
        ),
      );
    }

    // Stile base per il testo principale
    final TextStyle baseStyle = context.textTheme.bodyMedium!.copyWith(
      height: 1.6,
      color: context.textPrimaryColor.withValues(alpha: 0.85),
    );

    // Dividiamo il contenuto in paragrafi
    final paragraphs = content.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        // Verifichiamo se è un titolo di sezione (inizia con un numero seguito da punto)
        if (RegExp(r'^\d+\.\s').hasMatch(paragraph)) {
          // È un titolo di sezione
          return Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
            child: Text(
              paragraph,
              style: context.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
          );
        }
        // Verificare se è un elenco puntato
        else if (paragraph.contains('\n- ')) {
          // Dividiamo in titolo e punti elenco
          final parts = paragraph.split('\n- ');
          final title = parts.first;
          final bulletPoints = parts.sublist(1);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty && title != '-')
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    title,
                    style: baseStyle.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ...bulletPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: baseStyle,
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          );
        }
        // Paragrafo normale
        else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              paragraph,
              style: baseStyle,
            ),
          );
        }
      }).toList(),
    );
  }
}
