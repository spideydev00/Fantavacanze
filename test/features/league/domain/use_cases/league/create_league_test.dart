import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/create_league.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/partner_fixtures.dart';

class MockLeagueRepository extends Mock implements LeagueRepository {}

void main() {
  late MockLeagueRepository repository;
  late CreateLeague useCase;

  setUpAll(() {
    registerFallbackValue(LeagueType.individual);
    registerFallbackValue(<Rule>[]);
  });

  setUp(() {
    repository = MockLeagueRepository();
    useCase = CreateLeague(leagueRepository: repository);
  });

  test('passes partnerDestinationId through to the repository', () async {
    when(() => repository.createLeague(
          name: any(named: 'name'),
          description: any(named: 'description'),
          type: any(named: 'type'),
          rules: any(named: 'rules'),
          partnerDestinationId: any(named: 'partnerDestinationId'),
        )).thenAnswer((_) async => Right(tPartnerLeagueModel));

    final result = await useCase(const CreateLeagueParams(
      name: 'Lega B-Eazy',
      description: 'Package partner',
      type: LeagueType.individual,
      rules: [],
      partnerDestinationId: 'dest-package-1',
    ));

    expect(result, Right(tPartnerLeagueModel));
    verify(() => repository.createLeague(
          name: 'Lega B-Eazy',
          description: 'Package partner',
          type: LeagueType.individual,
          rules: [],
          partnerDestinationId: 'dest-package-1',
        )).called(1);
  });
}
