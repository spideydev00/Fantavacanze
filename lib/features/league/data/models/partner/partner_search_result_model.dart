import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/partner/partner_search_result.dart';

class PartnerSearchResultModel extends PartnerSearchResult {
  const PartnerSearchResultModel({
    required super.status,
    super.league,
    super.destinationName,
    super.roundName,
    super.requiresPassword,
  });

  factory PartnerSearchResultModel.fromJson(
    Map<String, dynamic> json, {
    League? league,
  }) {
    final leagueJson = json['league'];
    final leagueMap =
        leagueJson is Map ? Map<String, dynamic>.from(leagueJson) : null;

    return PartnerSearchResultModel(
      status: _statusFromJson(json['status'] as String?),
      league: league,
      destinationName: (json['destination_name'] ??
          leagueMap?['destination_name']) as String?,
      roundName: (json['round_name'] ?? leagueMap?['round_name']) as String?,
      requiresPassword: (json['requires_password'] ??
              json['requiresPassword'] ??
              leagueMap?['requires_password'] ??
              leagueMap?['requiresPassword']) as bool? ??
          false,
    );
  }

  static PartnerSearchStatus _statusFromJson(String? status) {
    return switch (status) {
      'found' => PartnerSearchStatus.found,
      'not_found' => PartnerSearchStatus.notFound,
      'wrong_password' => PartnerSearchStatus.wrongPassword,
      _ => PartnerSearchStatus.notFound,
    };
  }
}
