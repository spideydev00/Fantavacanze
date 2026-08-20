import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/drop/drop_cubit.dart';
import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';
import 'package:fantavacanze_official/features/drop/presentation/pages/drop_poster_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDropCubit extends MockCubit<DropState> implements DropCubit {}

void main() {
  late MockDropCubit cubit;

  const drop = Drop(
    code: 'estate-2026',
    imageUrl: 'https://esempio/estate-2026.png',
    ctaLabel: 'Scopri il drop',
    ctaUrl: 'https://fvstore.it/collections/estate',
  );

  const invalidDrop = Drop(
    code: 'estate-2026',
    imageUrl: 'https://esempio/estate-2026.png',
    ctaLabel: 'Scopri il drop',
    ctaUrl: 'https://[',
  );

  setUp(() {
    cubit = MockDropCubit();
    when(() => cubit.state).thenReturn(const DropVisible(drop));
    when(() => cubit.dismiss()).thenAnswer((_) async {});
  });

  Widget wrap([Drop value = drop]) => MaterialApp(
        home: BlocProvider<DropCubit>.value(
          value: cubit,
          child: DropPosterPage(drop: value),
        ),
      );

  testWidgets('mostra la CTA remota e il comando Chiudi', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Scopri il drop'), findsOneWidget);
    expect(find.text('Chiudi'), findsOneWidget);
  });

  testWidgets('Chiudi marca il drop come visto', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Chiudi'));

    verify(() => cubit.dismiss()).called(1);
  });

  testWidgets('una CTA non valida lascia il poster aperto', (tester) async {
    await tester.pumpWidget(wrap(invalidDrop));
    await tester.tap(find.text('Scopri il drop'));
    await tester.pump();

    verifyNever(() => cubit.dismiss());
    expect(
      find.text('Non riesco ad aprire il link, riprova più tardi.'),
      findsOneWidget,
    );
  });
}
