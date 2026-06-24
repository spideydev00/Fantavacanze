import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/create_partner_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/get_partner_destinations.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/get_partner_general_ranking.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/join_partner_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/partner/search_partner_league.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/partner_fixtures.dart';

class MockLeagueRepository extends Mock implements LeagueRepository {}

void main() {
  late MockLeagueRepository repository;

  setUp(() => repository = MockLeagueRepository());

  final tFailure = Failure('Errore di rete');

  group('GetPartnerDestinations', () {
    late GetPartnerDestinations useCase;
    setUp(() => useCase = GetPartnerDestinations(leagueRepository: repository));

    test('forwards the catalog from the repository on success', () async {
      when(() => repository.getPartnerDestinations('invibe'))
          .thenAnswer((_) async => Right(tPartnerCatalog));

      final result = await useCase(
        const GetPartnerDestinationsParams(partnerSlug: 'invibe'),
      );

      expect(result, Right(tPartnerCatalog));
      verify(() => repository.getPartnerDestinations('invibe')).called(1);
    });

    test('forwards Failure from the repository', () async {
      when(() => repository.getPartnerDestinations(any()))
          .thenAnswer((_) async => Left(tFailure));

      final result = await useCase(
        const GetPartnerDestinationsParams(partnerSlug: 'invibe'),
      );

      expect(result, Left(tFailure));
    });
  });

  group('CreatePartnerLeague', () {
    late CreatePartnerLeague useCase;
    setUp(() => useCase = CreatePartnerLeague(leagueRepository: repository));

    test('passes every param through to the repository', () async {
      when(() => repository.createPartnerLeague(
            userName: any(named: 'userName'),
            destinationId: any(named: 'destinationId'),
            name: any(named: 'name'),
            password: any(named: 'password'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => Right(tPartnerLeagueModel));

      final result = await useCase(const CreatePartnerLeagueParams(
        userName: 'Mario',
        destinationId: 'dest-1',
        name: 'La mia lega',
        password: 'LUGLIO26',
        description: 'desc',
      ));

      expect(result, Right(tPartnerLeagueModel));
      verify(() => repository.createPartnerLeague(
            userName: 'Mario',
            destinationId: 'dest-1',
            name: 'La mia lega',
            password: 'LUGLIO26',
            description: 'desc',
          )).called(1);
    });

    test('forwards Failure (e.g. wrong password) from the repository', () async {
      when(() => repository.createPartnerLeague(
            userName: any(named: 'userName'),
            destinationId: any(named: 'destinationId'),
            name: any(named: 'name'),
            password: any(named: 'password'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => Left(Failure('Parola d\'ordine errata')));

      final result = await useCase(const CreatePartnerLeagueParams(
        userName: 'Mario',
        destinationId: 'dest-1',
        name: 'La mia lega',
        password: 'sbagliata',
      ));

      expect(result.isLeft(), true);
    });
  });

  group('SearchPartnerLeague', () {
    late SearchPartnerLeague useCase;
    setUp(() => useCase = SearchPartnerLeague(leagueRepository: repository));

    test('forwards the search result on success', () async {
      when(() => repository.searchPartnerLeague(
            inviteCode: 'vb12345678',
            password: 'LUGLIO26',
          )).thenAnswer((_) async => Right(tPartnerSearchResultFound));

      final result = await useCase(const SearchPartnerLeagueParams(
        inviteCode: 'vb12345678',
        password: 'LUGLIO26',
      ));

      expect(result, Right(tPartnerSearchResultFound));
    });
  });

  group('JoinPartnerLeague', () {
    late JoinPartnerLeague useCase;
    setUp(() => useCase = JoinPartnerLeague(leagueRepository: repository));

    test('passes every param through and returns the joined league', () async {
      when(() => repository.joinPartnerLeague(
            userName: any(named: 'userName'),
            inviteCode: any(named: 'inviteCode'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(tPartnerLeagueModel));

      final result = await useCase(const JoinPartnerLeagueParams(
        userName: 'Mario',
        inviteCode: 'vb12345678',
        password: 'LUGLIO26',
      ));

      expect(result, Right(tPartnerLeagueModel));
      verify(() => repository.joinPartnerLeague(
            userName: 'Mario',
            inviteCode: 'vb12345678',
            password: 'LUGLIO26',
          )).called(1);
    });
  });

  group('GetPartnerGeneralRanking', () {
    late GetPartnerGeneralRanking useCase;
    setUp(() => useCase = GetPartnerGeneralRanking(leagueRepository: repository));

    test('forwards the ranking list on success', () async {
      when(() => repository.getPartnerGeneralRanking('league-1'))
          .thenAnswer((_) async => const Right(tGeneralRanking));

      final result = await useCase(
        const GetPartnerGeneralRankingParams(leagueId: 'league-1'),
      );

      expect(result, const Right(tGeneralRanking));
      verify(() => repository.getPartnerGeneralRanking('league-1')).called(1);
    });
  });
}
