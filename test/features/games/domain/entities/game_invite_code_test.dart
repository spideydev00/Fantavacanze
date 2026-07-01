import 'package:fantavacanze_official/features/games/domain/entities/game_invite_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeGameInviteCode', () {
    test('normalizes plain game codes', () {
      expect(normalizeGameInviteCode(' 85782a9 '), '85782A9');
      expect(normalizeGameInviteCode('w12ab3b'), 'W12AB3B');
    });

    test('extracts the code from shared text', () {
      expect(
        normalizeGameInviteCode(
          'Unisciti alla mia partita su Fantavacanze! Codice: W12AB3B',
        ),
        'W12AB3B',
      );
    });

    test('rejects uuid fragments', () {
      expect(normalizeGameInviteCode('d77fb620-2'), isNull);
      expect(isExactGameInviteCode('d77fb620-2'), isFalse);
    });
  });
}
