import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_destination.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_round.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/create_partner_league_page.dart';
import 'package:flutter_test/flutter_test.dart';

PartnerDestination _destination(String id, DateTime? start) {
  return PartnerDestination(
    id: id,
    name: id,
    rules: const [],
    rounds: start == null
        ? const []
        : [PartnerRound(id: '$id-r', name: '$id round', startDate: start)],
  );
}

void main() {
  group('sortDestinationsByImminentRound', () {
    test('orders by first round startDate ascending', () {
      final input = [
        _destination('late', DateTime(2026, 8, 1)),
        _destination('soon', DateTime(2026, 7, 9)),
        _destination('mid', DateTime(2026, 7, 20)),
      ];

      final out = sortDestinationsByImminentRound(input);

      expect(out.map((destination) => destination.id), [
        'soon',
        'mid',
        'late',
      ]);
    });

    test('destinations without rounds go last', () {
      final input = [
        _destination('noround', null),
        _destination('dated', DateTime(2026, 7, 9)),
      ];

      final out = sortDestinationsByImminentRound(input);

      expect(out.map((destination) => destination.id), ['dated', 'noround']);
    });

    test('does not mutate the input list', () {
      final input = [
        _destination('b', DateTime(2026, 8, 1)),
        _destination('a', DateTime(2026, 7, 1)),
      ];

      sortDestinationsByImminentRound(input);

      expect(input.map((destination) => destination.id), ['b', 'a']);
    });

    test(
      'ordina per il turno più imminente e mette in fondo le destinazioni '
      'senza turni',
      () {
        final withEarly = PartnerDestination(
          id: 'a',
          name: 'A',
          rules: const [],
          rounds: [
            PartnerRound(
              id: 'r',
              name: 'T',
              startDate: DateTime(2026, 7, 16),
            ),
          ],
        );
        final withLate = PartnerDestination(
          id: 'b',
          name: 'B',
          rules: const [],
          rounds: [
            PartnerRound(
              id: 'r',
              name: 'T',
              startDate: DateTime(2026, 7, 24),
            ),
          ],
        );
        const noRounds = PartnerDestination(
          id: 'c',
          name: 'C',
          rules: [],
          rounds: [],
        );

        final sorted = sortDestinationsByImminentRound([
          withLate,
          noRounds,
          withEarly,
        ]);

        expect(sorted.map((d) => d.id).toList(), ['a', 'b', 'c']);
      },
    );
  });
}
