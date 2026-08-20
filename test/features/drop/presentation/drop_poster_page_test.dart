import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/drop/drop_cubit.dart';
import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';
import 'package:fantavacanze_official/features/drop/presentation/pages/drop_poster_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MockDropCubit extends MockCubit<DropState> implements DropCubit {}

void main() {
  late MockDropCubit cubit;

  final drop = Drop(
    code: 'estate-2026',
    imageUrls: [
      'https://esempio/estate-2026-1.png',
      'https://esempio/estate-2026-2.png',
      'https://esempio/estate-2026-3.png',
    ],
    imageDescriptions: ['Maglietta nera', 'Felpa bianca', 'Cappellino nero'],
    ctaLabel: 'Scopri il drop',
    ctaUrl: 'https://fvstore.it/collections/estate',
  );

  final invalidDrop = Drop(
    code: 'estate-2026',
    imageUrls: [
      'https://esempio/estate-2026-1.png',
      'https://esempio/estate-2026-2.png',
      'https://esempio/estate-2026-3.png',
    ],
    imageDescriptions: ['Maglietta nera', 'Felpa bianca', 'Cappellino nero'],
    ctaLabel: 'Scopri il drop',
    ctaUrl: 'https://[',
  );

  final brokenDrop = Drop(
    code: 'estate-2026',
    imageUrls: [
      'https://non-raggiungibile.invalid/1.png',
      'https://non-raggiungibile.invalid/2.png',
      'https://non-raggiungibile.invalid/3.png',
    ],
    imageDescriptions: ['Maglietta nera', 'Felpa bianca', 'Cappellino nero'],
    ctaLabel: 'Scopri il drop',
    ctaUrl: 'https://fvstore.it/',
  );

  setUp(() {
    cubit = MockDropCubit();
    when(() => cubit.state).thenReturn(DropVisible(drop));
    when(() => cubit.dismiss()).thenAnswer((_) async {});
  });

  Widget wrap([Drop? value, DropImagesPreloader? imagePreloader]) {
    final selectedDrop = value ?? drop;
    final page = imagePreloader == null
        ? DropPosterPage(drop: selectedDrop)
        : DropPosterPage(
            drop: selectedDrop,
            imagePreloader: imagePreloader,
          );
    return MaterialApp(
      home: BlocProvider<DropCubit>.value(value: cubit, child: page),
    );
  }

  Future<void> pumpPage(WidgetTester tester, [Drop? value]) async {
    const transparentPixel =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';
    final frame = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(
        base64Decode(transparentPixel),
      );
      return codec.getNextFrame();
    });
    final image = frame!.image;
    final selectedDrop = value ?? drop;
    for (final url in selectedDrop.imageUrls) {
      final provider = CachedNetworkImageProvider(url);
      PaintingBinding.instance.imageCache.putIfAbsent(
        provider,
        () => OneFrameImageStreamCompleter(
          Future.value(ImageInfo(image: image.clone())),
        ),
      );
    }
    image.dispose();

    await tester.pumpWidget(wrap(selectedDrop));
    await tester.pump();
  }

  tearDown(() {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  });

  testWidgets('mostra la CTA remota e il comando Chiudi', (tester) async {
    await pumpPage(tester);

    expect(find.text('Scopri il drop'), findsOneWidget);
    expect(find.text('Chiudi'), findsOneWidget);
  });

  testWidgets('mostra un carosello con tre immagini e tre indicatori',
      (tester) async {
    await pumpPage(tester);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller, isNotNull);
    final delegate = pageView.childrenDelegate;
    final childCount = switch (delegate) {
      SliverChildBuilderDelegate(:final childCount) => childCount,
      SliverChildListDelegate(:final children) => children.length,
      _ => null,
    };
    expect(childCount, 3);
    expect(find.byType(CachedNetworkImage), findsWidgets);

    final indicator = tester.widget<SmoothPageIndicator>(
      find.byType(SmoothPageIndicator),
    );
    expect(indicator.count, 3);

    final semantics = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel('Maglietta nera. Prodotto 1 di 3'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('lo swipe porta alla seconda immagine del carosello',
      (tester) async {
    await pumpPage(tester);

    final pageViewFinder = find.byType(PageView);
    final pageView = tester.widget<PageView>(pageViewFinder);
    final controller = pageView.controller!;

    await tester.fling(pageViewFinder, const Offset(-500, 0), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.page, 1);
  });

  testWidgets('Chiudi marca il drop come visto', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Chiudi'));

    verify(() => cubit.dismiss()).called(1);
  });

  testWidgets('un preload fallito nasconde il drop senza abilitare le azioni',
      (tester) async {
    await tester.pumpWidget(wrap(brokenDrop, (_, __) async => false));
    await tester.pump();

    verify(() => cubit.imageFailed()).called(1);
    verifyNever(() => cubit.dismiss());
    expect(find.text('Chiudi'), findsNothing);
  });

  testWidgets('una CTA non valida lascia il poster aperto', (tester) async {
    await pumpPage(tester, invalidDrop);
    await tester.tap(find.text('Scopri il drop'));
    await tester.pump();

    verifyNever(() => cubit.dismiss());
    expect(
      find.text('Non riesco ad aprire il link, riprova più tardi.'),
      findsOneWidget,
    );
  });
}
