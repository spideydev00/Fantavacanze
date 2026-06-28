import '../../../domain/entities/partner/general_ranking_entry.dart';

class GeneralRankingEntryModel extends GeneralRankingEntry {
  const GeneralRankingEntryModel({
    required super.userId,
    required super.name,
    required super.points,
    required super.bonusTotal,
    required super.malusTotal,
    required super.leagueName,
  });

  factory GeneralRankingEntryModel.fromJson(Map<String, dynamic> json) {
    final userId = (json['user_id'] ?? json['userId']) as String;
    final name = json['name'] as String;
    final points = (json['points'] as num).toDouble();
    final bonusTotal =
        ((json['bonus_total'] ?? json['bonusTotal']) as num?)?.toDouble() ?? 0;
    final malusTotal =
        ((json['malus_total'] ?? json['malusTotal']) as num?)?.toDouble() ?? 0;
    final leagueName = (json['league_name'] ?? json['leagueName']) as String;

    return GeneralRankingEntryModel(
      userId: userId,
      name: name,
      points: points,
      bonusTotal: bonusTotal,
      malusTotal: malusTotal,
      leagueName: leagueName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'points': points,
      'bonus_total': bonusTotal,
      'malus_total': malusTotal,
      'league_name': leagueName,
    };
  }
}
