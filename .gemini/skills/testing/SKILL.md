---
name: testing
description: "Write, review, and improve Flutter and Dart tests including unit tests, widget tests, and bloc tests. Use when writing new tests, reviewing test quality, fixing flaky tests, or choosing between unit and widget tests. Uses mocktail for mocking and bloc_test for BLoC/Cubit assertions."
---

# Testing Skill

Write effective, meaningful Flutter and Dart tests that catch real regressions.

## When to Use

Use this skill when:

* Writing unit tests for use cases, repositories, or utility classes.
* Writing BLoC/Cubit tests using `bloc_test`.
* Writing widget tests for UI components.
* Reviewing existing tests for correctness.
* Fixing flaky or false-positive tests.

---

## 1. Test Validity

Before writing or accepting a test, ask:

> **"Can this test actually fail if the real code is broken?"**

- Avoid tests that only confirm mocked behavior without exercising real logic.
- Every test must be capable of catching a real regression.

```dart
// BAD — tests the mock, not real logic
test('should return leagues', () {
  when(() => repo.getUserLeagues()).thenReturn(right(fakeLeagues));
  expect(repo.getUserLeagues(), isA<Right>()); // Only proves the mock works
});

// GOOD — tests that the BLoC correctly transitions state based on use case result
blocTest<LeagueBloc, LeagueState>(
  'emits [LeagueLoading, LeagueLoaded] when GetLeagueEvent succeeds',
  build: () {
    when(() => getLeague(any())).thenAnswer((_) async => right(fakeLeague));
    return LeagueBloc(getLeague: getLeague);
  },
  act: (bloc) => bloc.add(const GetLeagueEvent('id')),
  expect: () => [isA<LeagueLoading>(), isA<LeagueLoaded>()],
);
```

---

## 2. Test Structure

Always use `group()` named after the **class under test**:

```dart
group('GetLeague', () {
  late LeagueRepository repository;
  late GetLeague useCase;

  setUp(() {
    repository = MockLeagueRepository();
    useCase = GetLeague(repository);
  });

  test('should return League when repository succeeds', () async {
    when(() => repository.getLeague(any())).thenAnswer((_) async => right(fakeLeague));

    final result = await useCase(const GetLeagueParams(leagueId: 'id'));

    expect(result, right(fakeLeague));
  });

  test('should return Failure when repository fails', () async {
    when(() => repository.getLeague(any())).thenAnswer((_) async => left(fakeFailure));

    final result = await useCase(const GetLeagueParams(leagueId: 'id'));

    expect(result, left(fakeFailure));
  });
});
```

---

## 3. Mocking with Mocktail

```dart
class MockLeagueRepository extends Mock implements LeagueRepository {}
class MockGetLeague extends Mock implements GetLeague {}
class FakeGetLeagueParams extends Fake implements GetLeagueParams {}
```

Register fallback values for custom types used with argument matchers:

```dart
setUpAll(() {
  registerFallbackValue(FakeGetLeagueParams());
});
```

Always call `registerFallbackValue` in `setUpAll`, not `setUp`.

---

## 4. Testing Use Cases

Use cases wrap repository calls, so test at this level to verify business logic:

```dart
group('MarkChallengeAsCompleted', () {
  late LeagueRepository repository;
  late MarkChallengeAsCompleted useCase;

  setUp(() {
    repository = MockLeagueRepository();
    useCase = MarkChallengeAsCompleted(repository);
  });

  test('should return Unit when completion succeeds', () async {
    when(() => repository.markChallengeAsCompleted(any()))
        .thenAnswer((_) async => right(unit));

    final result = await useCase(const MarkChallengeParams(challengeId: 'cid'));

    expect(result.isRight(), true);
  });

  test('should return Failure when repository fails', () async {
    when(() => repository.markChallengeAsCompleted(any()))
        .thenAnswer((_) async => left(Failure('Errore di rete')));

    final result = await useCase(const MarkChallengeParams(challengeId: 'cid'));

    expect(result.isLeft(), true);
  });
});
```

---

## 5. Testing BLoCs with bloc_test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockGetLeague extends Mock implements GetLeague {}
class FakeGetLeagueParams extends Fake implements GetLeagueParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGetLeagueParams());
  });

  group('LeagueBloc', () {
    late GetLeague getLeague;
    late LeagueBloc bloc;

    setUp(() {
      getLeague = MockGetLeague();
      bloc = LeagueBloc(getLeague: getLeague);
    });

    tearDown(() => bloc.close());

    blocTest<LeagueBloc, LeagueState>(
      'emits [LeagueLoading, LeagueLoaded] on success',
      build: () {
        when(() => getLeague(any())).thenAnswer((_) async => right(fakeLeague));
        return bloc;
      },
      act: (b) => b.add(const GetLeagueEvent('id')),
      expect: () => [isA<LeagueLoading>(), isA<LeagueLoaded>()],
      verify: (_) {
        verify(() => getLeague(any())).called(1);
      },
    );

    blocTest<LeagueBloc, LeagueState>(
      'emits [LeagueLoading, LeagueError] on failure',
      build: () {
        when(() => getLeague(any()))
            .thenAnswer((_) async => left(Failure('Errore')));
        return bloc;
      },
      act: (b) => b.add(const GetLeagueEvent('id')),
      expect: () => [isA<LeagueLoading>(), isA<LeagueError>()],
    );
  });
}
```

Rules:
- Always `tearDown(() => bloc.close())`.
- Use `isA<StateType>()` rather than exact instances when state equality is complex.
- Mock use cases at the BLoC test level (not repositories).
- Mock repositories at the use case or repository-impl test level.

---

## 6. Testing Repositories

Test that `Either` results are returned correctly and exceptions are mapped to `Failure`:

```dart
group('LeagueRepositoryImpl', () {
  late LeagueRemoteDataSource remoteDataSource;
  late LeagueLocalDataSource localDataSource;
  late ConnectionChecker connectionChecker;
  late LeagueRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockLeagueRemoteDataSource();
    localDataSource = MockLeagueLocalDataSource();
    connectionChecker = MockConnectionChecker();
    repository = LeagueRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      connectionChecker: connectionChecker,
    );
  });

  test('returns cached leagues when cache is not empty', () async {
    when(() => localDataSource.getCachedLeagues())
        .thenAnswer((_) async => [fakeLeagueModel]);

    final result = await repository.getUserLeagues();

    expect(result.isRight(), true);
    verifyNever(() => remoteDataSource.getUserLeagues());
  });

  test('returns Failure on ServerException', () async {
    when(() => localDataSource.getCachedLeagues()).thenAnswer((_) async => []);
    when(() => connectionChecker.isConnected).thenAnswer((_) async => true);
    when(() => remoteDataSource.getUserLeagues())
        .thenThrow(ServerException('Errore server'));

    final result = await repository.getUserLeagues();

    expect(result.isLeft(), true);
  });
});
```

---

## 7. Rules

- Prefer real objects over mocks when practical.
- Use `Fake` (`extends Fake`) when you don't need interaction verification.
- Use `Mock` (`extends Mock`) only when you need `verify` assertions.
- Do not test behavior guaranteed by the language or standard library.
- Keep tests small and focused — one logical assertion per test case.
- Name test cases with the expected outcome: "should return X when Y".
