import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_catalog.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_search_result.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/create_partner_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/get_partner_destinations.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/get_partner_general_ranking.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/join_partner_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/search_partner_league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/partner_fixtures.dart';

class MockGetPartnerDestinations extends Mock
    implements GetPartnerDestinations {}

class MockCreatePartnerLeague extends Mock implements CreatePartnerLeague {}

class MockSearchPartnerLeague extends Mock implements SearchPartnerLeague {}

class MockJoinPartnerLeague extends Mock implements JoinPartnerLeague {}

class MockGetPartnerGeneralRanking extends Mock
    implements GetPartnerGeneralRanking {}

class MockAppLeagueCubit extends Mock implements AppLeagueCubit {}

class FakeGetPartnerDestinationsParams extends Fake
    implements GetPartnerDestinationsParams {}

class FakeCreatePartnerLeagueParams extends Fake
    implements CreatePartnerLeagueParams {}

class FakeSearchPartnerLeagueParams extends Fake
    implements SearchPartnerLeagueParams {}

class FakeJoinPartnerLeagueParams extends Fake
    implements JoinPartnerLeagueParams {}

class FakeGetPartnerGeneralRankingParams extends Fake
    implements GetPartnerGeneralRankingParams {}

void main() {
  late MockGetPartnerDestinations getDestinations;
  late MockCreatePartnerLeague createLeague;
  late MockSearchPartnerLeague searchLeague;
  late MockJoinPartnerLeague joinLeague;
  late MockGetPartnerGeneralRanking getRanking;
  late MockAppLeagueCubit appLeagueCubit;

  setUpAll(() {
    registerFallbackValue(FakeGetPartnerDestinationsParams());
    registerFallbackValue(FakeCreatePartnerLeagueParams());
    registerFallbackValue(FakeSearchPartnerLeagueParams());
    registerFallbackValue(FakeJoinPartnerLeagueParams());
    registerFallbackValue(FakeGetPartnerGeneralRankingParams());
  });

  setUp(() {
    getDestinations = MockGetPartnerDestinations();
    createLeague = MockCreatePartnerLeague();
    searchLeague = MockSearchPartnerLeague();
    joinLeague = MockJoinPartnerLeague();
    getRanking = MockGetPartnerGeneralRanking();
    appLeagueCubit = MockAppLeagueCubit();
  });

  PartnerCubit buildCubit() {
    return PartnerCubit(
      getPartnerDestinations: getDestinations,
      createPartnerLeague: createLeague,
      searchPartnerLeague: searchLeague,
      joinPartnerLeague: joinLeague,
      getPartnerGeneralRanking: getRanking,
      appLeagueCubit: appLeagueCubit,
    );
  }

  group('PartnerCubit', () {
    test('loadDestinations non emette dopo close', () async {
      final completer = Completer<Either<Failure, PartnerCatalog>>();
      when(() => getDestinations(any())).thenAnswer((_) => completer.future);

      final cubit = buildCubit();
      final future = cubit.loadDestinations('invibe');
      await Future<void>.delayed(Duration.zero);

      await cubit.close();
      completer.complete(right(tPartnerCatalog));

      await expectLater(future, completes);
    });

    blocTest<PartnerCubit, PartnerState>(
      'emette [Loading, DestinationsLoaded] quando loadDestinations ha successo',
      build: () {
        when(() => getDestinations(any()))
            .thenAnswer((_) async => right(tPartnerCatalog));
        return buildCubit();
      },
      act: (cubit) => cubit.loadDestinations('invibe'),
      expect: () => [
        const PartnerLoading(),
        PartnerDestinationsLoaded(tPartnerCatalog),
      ],
      verify: (_) {
        verify(() => getDestinations(any())).called(1);
      },
    );

    blocTest<PartnerCubit, PartnerState>(
      'emette [Loading, Failure] quando loadDestinations fallisce',
      build: () {
        when(() => getDestinations(any()))
            .thenAnswer((_) async => left(Failure('Errore')));
        return buildCubit();
      },
      act: (cubit) => cubit.loadDestinations('invibe'),
      expect: () => const [
        PartnerLoading(),
        PartnerFailure('Errore'),
      ],
    );

    blocTest<PartnerCubit, PartnerState>(
      'emette [Loading, LeagueReady] e aggiorna le leghe dopo createLeague',
      build: () {
        when(() => createLeague(any()))
            .thenAnswer((_) async => right(tPartnerLeagueModel));
        when(() => appLeagueCubit.getUserLeagues()).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.createLeague(
        userName: 'Mario',
        destinationId: 'dest-1',
        name: 'Lega InVibe',
        password: 'password',
        roundId: 'round-1',
      ),
      expect: () => [
        const PartnerLoading(),
        PartnerLeagueReady(tPartnerLeagueModel),
      ],
      verify: (_) {
        final captured = verify(() => createLeague(captureAny()))
            .captured
            .single as CreatePartnerLeagueParams;
        expect(captured.roundId, 'round-1');
        verify(() => appLeagueCubit.getUserLeagues()).called(1);
      },
    );

    blocTest<PartnerCubit, PartnerState>(
      'emette [Loading, SearchLoaded] quando searchLeague ha successo',
      build: () {
        const result = PartnerSearchResult(
          status: PartnerSearchStatus.notFound,
        );
        when(() => searchLeague(any())).thenAnswer((_) async => right(result));
        return buildCubit();
      },
      act: (cubit) => cubit.searchLeague(
        inviteCode: 'vbABC',
        password: 'password',
      ),
      expect: () => const [
        PartnerLoading(),
        PartnerSearchLoaded(
          PartnerSearchResult(status: PartnerSearchStatus.notFound),
        ),
      ],
    );

    blocTest<PartnerCubit, PartnerState>(
      'emette [Loading, LeagueReady] e aggiorna le leghe dopo joinLeague',
      build: () {
        when(() => joinLeague(any()))
            .thenAnswer((_) async => right(tPartnerLeagueModel));
        when(() => appLeagueCubit.getUserLeagues()).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.joinLeague(
        userName: 'Mario',
        inviteCode: 'vbABC',
        password: 'password',
      ),
      expect: () => [
        const PartnerLoading(),
        PartnerLeagueReady(tPartnerLeagueModel),
      ],
      verify: (_) {
        verify(() => joinLeague(any())).called(1);
        verify(() => appLeagueCubit.getUserLeagues()).called(1);
      },
    );

    blocTest<PartnerCubit, PartnerState>(
      'emette [Loading, RankingLoaded] quando loadGeneralRanking ha successo',
      build: () {
        when(() => getRanking(any()))
            .thenAnswer((_) async => right(tGeneralRanking));
        return buildCubit();
      },
      act: (cubit) => cubit.loadGeneralRanking('league-1'),
      expect: () => const [
        PartnerLoading(),
        PartnerRankingLoaded(tGeneralRanking),
      ],
    );
  });
}
