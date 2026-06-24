import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/league/data/datasources/local/local_data_source.dart';
import 'package:fantavacanze_official/features/league/data/datasources/remote/league_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model/league_model.dart';
import 'package:fantavacanze_official/features/league/data/repository/league_repository_impl.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_search_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/partner_fixtures.dart';

class MockRemoteDataSource extends Mock implements LeagueRemoteDataSource {}

class MockLocalDataSource extends Mock implements LocalDataSource {}

class MockConnectionChecker extends Mock implements ConnectionChecker {}

class FakeLeagueModel extends Fake implements LeagueModel {}

void main() {
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late MockConnectionChecker connection;
  late LeagueRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(FakeLeagueModel()));

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    connection = MockConnectionChecker();
    repository = LeagueRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      connectionChecker: connection,
    );
    when(() => connection.isConnected).thenAnswer((_) async => true);
    when(() => local.cacheLeague(any())).thenAnswer((_) async {});
  });

  group('getPartnerDestinations', () {
    test('returns Right(catalog) when connected and remote succeeds', () async {
      when(() => remote.getPartnerDestinations('invibe'))
          .thenAnswer((_) async => tPartnerCatalog);

      final result = await repository.getPartnerDestinations('invibe');

      expect(result.isRight(), true);
      result.match((_) => fail('expected Right'),
          (c) => expect(c, tPartnerCatalog));
    });

    test('returns Left when offline (no remote call)', () async {
      when(() => connection.isConnected).thenAnswer((_) async => false);

      final result = await repository.getPartnerDestinations('invibe');

      expect(result.isLeft(), true);
      verifyNever(() => remote.getPartnerDestinations(any()));
    });

    test('maps ServerException to Left(Failure)', () async {
      when(() => remote.getPartnerDestinations(any()))
          .thenThrow(ServerException('Partner non trovato'));

      final result = await repository.getPartnerDestinations('invibe');

      result.match((f) => expect(f.message, 'Partner non trovato'),
          (_) => fail('expected Left'));
    });
  });

  group('createPartnerLeague', () {
    test('caches the league and returns Right on success', () async {
      when(() => remote.createPartnerLeague(
            destinationId: any(named: 'destinationId'),
            name: any(named: 'name'),
            password: any(named: 'password'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => tPartnerLeagueModel);

      final result = await repository.createPartnerLeague(
        userName: 'Mario',
        destinationId: 'dest-1',
        name: 'La mia lega',
        password: 'LUGLIO26',
      );

      expect(result.isRight(), true);
      verify(() => local.cacheLeague(tPartnerLeagueModel)).called(1);
    });

    test('does not cache and returns Left on ServerException', () async {
      when(() => remote.createPartnerLeague(
            destinationId: any(named: 'destinationId'),
            name: any(named: 'name'),
            password: any(named: 'password'),
            description: any(named: 'description'),
          )).thenThrow(ServerException('Parola d\'ordine errata'));

      final result = await repository.createPartnerLeague(
        userName: 'Mario',
        destinationId: 'dest-1',
        name: 'La mia lega',
        password: 'sbagliata',
      );

      result.match((f) => expect(f.message, 'Parola d\'ordine errata'),
          (_) => fail('expected Left'));
      verifyNever(() => local.cacheLeague(any()));
    });
  });

  group('searchPartnerLeague', () {
    test('returns Right(result) without caching', () async {
      when(() => remote.searchPartnerLeague(
            inviteCode: any(named: 'inviteCode'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tPartnerSearchResultFound);

      final result = await repository.searchPartnerLeague(
        inviteCode: 'vb12345678',
        password: 'LUGLIO26',
      );

      result.match((_) => fail('expected Right'),
          (r) => expect(r.status, PartnerSearchStatus.found));
      verifyNever(() => local.cacheLeague(any()));
    });
  });

  group('joinPartnerLeague', () {
    test('caches the league and returns Right on success', () async {
      when(() => remote.joinPartnerLeague(
            inviteCode: any(named: 'inviteCode'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tPartnerLeagueModel);

      final result = await repository.joinPartnerLeague(
        userName: 'Mario',
        inviteCode: 'vb12345678',
        password: 'LUGLIO26',
      );

      expect(result.isRight(), true);
      verify(() => local.cacheLeague(tPartnerLeagueModel)).called(1);
    });
  });

  group('getPartnerGeneralRanking', () {
    test('returns Right(list) on success', () async {
      when(() => remote.getPartnerGeneralRanking('league-1'))
          .thenAnswer((_) async => tGeneralRankingModels);

      final result = await repository.getPartnerGeneralRanking('league-1');

      result.match((_) => fail('expected Right'),
          (list) => expect(list.length, 2));
    });

    test('maps ServerException to Left(Failure)', () async {
      when(() => remote.getPartnerGeneralRanking(any()))
          .thenThrow(ServerException('Errore server'));

      final result = await repository.getPartnerGeneralRanking('league-1');

      expect(result.isLeft(), true);
    });
  });
}
