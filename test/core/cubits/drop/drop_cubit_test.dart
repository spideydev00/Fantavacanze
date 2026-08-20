import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/drop/drop_cubit.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';
import 'package:fantavacanze_official/features/drop/domain/use_cases/get_drop_check.dart';
import 'package:fantavacanze_official/features/drop/domain/use_cases/mark_drop_seen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDropCheck extends Mock implements GetDropCheck {}

class MockMarkDropSeen extends Mock implements MarkDropSeen {}

void main() {
  late MockGetDropCheck getDropCheck;
  late MockMarkDropSeen markDropSeen;

  const drop = Drop(
    code: 'estate-2026',
    imageUrl: 'https://esempio/estate-2026.png',
    ctaLabel: 'Scopri il drop',
    ctaUrl: 'https://fvstore.it/collections/estate',
  );

  DropCubit build() => DropCubit(
        getDropCheck: getDropCheck,
        markDropSeen: markDropSeen,
      );

  setUpAll(() => registerFallbackValue(NoParams()));

  setUp(() {
    getDropCheck = MockGetDropCheck();
    markDropSeen = MockMarkDropSeen();
    when(() => markDropSeen.call(any())).thenAnswer((_) async => right(unit));
  });

  blocTest<DropCubit, DropState>(
    'mostra il poster quando il drop attivo non è quello già visto',
    setUp: () => when(() => getDropCheck.call(any())).thenAnswer(
      (_) async =>
          right(const DropCheck(drop: drop, lastSeenDrop: 'estate-2025')),
    ),
    build: build,
    act: (cubit) => cubit.check(),
    expect: () => [isA<DropVisible>()],
  );

  blocTest<DropCubit, DropState>(
    'mostra il poster a chi non ha mai visto nulla',
    setUp: () => when(() => getDropCheck.call(any())).thenAnswer(
      (_) async => right(const DropCheck(drop: drop)),
    ),
    build: build,
    act: (cubit) => cubit.check(),
    expect: () => [isA<DropVisible>()],
  );

  blocTest<DropCubit, DropState>(
    'non mostra nulla quando il codice è già stato visto',
    setUp: () => when(() => getDropCheck.call(any())).thenAnswer(
      (_) async =>
          right(const DropCheck(drop: drop, lastSeenDrop: 'estate-2026')),
    ),
    build: build,
    act: (cubit) => cubit.check(),
    expect: () => <DropState>[],
  );

  blocTest<DropCubit, DropState>(
    'non mostra nulla quando non ci sono drop attivi',
    setUp: () => when(() => getDropCheck.call(any())).thenAnswer(
      (_) async => right(const DropCheck()),
    ),
    build: build,
    act: (cubit) => cubit.check(),
    expect: () => <DropState>[],
  );

  blocTest<DropCubit, DropState>(
    'non mostra nulla quando la lettura fallisce',
    setUp: () => when(
      () => getDropCheck.call(any()),
    ).thenAnswer((_) async => left(Failure('rete assente'))),
    build: build,
    act: (cubit) => cubit.check(),
    expect: () => <DropState>[],
  );

  blocTest<DropCubit, DropState>(
    'dismiss marca come visto e nasconde',
    setUp: () => when(() => getDropCheck.call(any())).thenAnswer(
      (_) async => right(const DropCheck(drop: drop)),
    ),
    build: build,
    act: (cubit) async {
      await cubit.check();
      await cubit.dismiss();
    },
    expect: () => [isA<DropVisible>(), isA<DropHidden>()],
    verify: (_) => verify(() => markDropSeen.call('estate-2026')).called(1),
  );

  blocTest<DropCubit, DropState>(
    'immagine rotta: nasconde senza marcare come visto',
    setUp: () => when(() => getDropCheck.call(any())).thenAnswer(
      (_) async => right(const DropCheck(drop: drop)),
    ),
    build: build,
    act: (cubit) async {
      await cubit.check();
      cubit.imageFailed();
    },
    expect: () => [isA<DropVisible>(), isA<DropHidden>()],
    verify: (_) => verifyNever(() => markDropSeen.call(any())),
  );
}
