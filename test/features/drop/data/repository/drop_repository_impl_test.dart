import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/drop/data/datasources/drop_remote_data_source.dart';
import 'package:fantavacanze_official/features/drop/data/models/drop_model.dart';
import 'package:fantavacanze_official/features/drop/data/repository/drop_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDropRemoteDataSource extends Mock implements DropRemoteDataSource {}

void main() {
  late MockDropRemoteDataSource dataSource;
  late DropRepositoryImpl repository;

  const drop = DropModel(
    code: 'estate-2026',
    imageUrl: 'https://esempio/estate-2026.png',
    ctaLabel: 'Scopri il drop',
    ctaUrl: 'https://fvstore.it/collections/estate',
  );

  setUp(() {
    dataSource = MockDropRemoteDataSource();
    repository = DropRepositoryImpl(remoteDataSource: dataSource);
  });

  group('getDropCheck', () {
    test('restituisce drop e ultimo visto quando entrambi ci sono', () async {
      when(() => dataSource.getActiveDrop()).thenAnswer((_) async => drop);
      when(() => dataSource.getLastSeenDrop())
          .thenAnswer((_) async => 'estate-2025');

      final result = await repository.getDropCheck();

      expect(result.isRight(), isTrue);
      final check = result.getRight().toNullable()!;
      expect(check.drop?.code, 'estate-2026');
      expect(check.lastSeenDrop, 'estate-2025');
    });

    test('restituisce drop nullo quando non ce ne sono di attivi', () async {
      when(() => dataSource.getActiveDrop()).thenAnswer((_) async => null);
      when(() => dataSource.getLastSeenDrop()).thenAnswer((_) async => null);

      final result = await repository.getDropCheck();

      expect(result.getRight().toNullable()!.drop, isNull);
    });

    test('restituisce Failure quando il datasource lancia', () async {
      when(() => dataSource.getActiveDrop())
          .thenThrow(ServerException('rete assente'));
      when(() => dataSource.getLastSeenDrop()).thenAnswer((_) async => null);

      final result = await repository.getDropCheck();

      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<Failure>());
    });
  });

  group('markSeen', () {
    test('restituisce unit in caso di successo', () async {
      when(() => dataSource.markSeen('estate-2026')).thenAnswer((_) async {});

      final result = await repository.markSeen('estate-2026');

      expect(result.isRight(), isTrue);
      verify(() => dataSource.markSeen('estate-2026')).called(1);
    });

    test('restituisce Failure quando il datasource lancia', () async {
      when(() => dataSource.markSeen(any()))
          .thenThrow(ServerException('permesso negato'));

      final result = await repository.markSeen('estate-2026');

      expect(result.isLeft(), isTrue);
    });
  });
}
