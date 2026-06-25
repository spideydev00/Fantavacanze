import 'package:fantavacanze_official/features/league/data/models/partner/partner_destination_model.dart';
import 'package:fantavacanze_official/features/league/data/models/partner/partner_search_result_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_search_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PartnerDestinationModel', () {
    test('maps requires_password from snake_case json', () {
      final model = PartnerDestinationModel.fromJson(const {
        'id': 'dest-1',
        'name': 'B-Eazy',
        'description': 'Package',
        'rules': [],
        'requires_password': true,
      });

      expect(model.requiresPassword, true);
      expect(model.toJson()['requires_password'], true);
    });

    test('defaults requiresPassword to false when missing', () {
      final model = PartnerDestinationModel.fromJson(const {
        'id': 'dest-1',
        'name': 'B-Eazy',
        'rules': [],
      });

      expect(model.requiresPassword, false);
    });
  });

  group('PartnerSearchResultModel', () {
    test('maps requires_password for wrong password results', () {
      final model = PartnerSearchResultModel.fromJson(const {
        'status': 'wrong_password',
        'requires_password': true,
      });

      expect(model.status, PartnerSearchStatus.wrongPassword);
      expect(model.requiresPassword, true);
    });

    test('maps destination metadata from nested league payload', () {
      final model = PartnerSearchResultModel.fromJson(const {
        'status': 'found',
        'league': {
          'destination_name': 'Gallipoli',
          'round_name': 'Turno 1',
          'requires_password': false,
        },
      });

      expect(model.status, PartnerSearchStatus.found);
      expect(model.destinationName, 'Gallipoli');
      expect(model.roundName, 'Turno 1');
      expect(model.requiresPassword, false);
    });
  });
}
