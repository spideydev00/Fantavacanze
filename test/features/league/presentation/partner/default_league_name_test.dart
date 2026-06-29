import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/utils/default_league_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('defaultLeagueName', () {
    test('male -> tori', () {
      expect(
        defaultLeagueName(gender: 'male', destination: 'Ibiza'),
        'I tori di Ibiza (scegli il tuo...)',
      );
    });

    test('female -> baddies', () {
      expect(
        defaultLeagueName(gender: 'female', destination: 'Ibiza'),
        'Le baddies di Ibiza (scegli il tuo...)',
      );
    });

    test('null -> generico', () {
      expect(
        defaultLeagueName(gender: null, destination: 'Ibiza'),
        'La lega di Ibiza (scegli il tuo...)',
      );
    });
  });
}
