import '../../../domain/entities/partner/general_ranking_entry.dart';

class GeneralRankingEntryModel extends GeneralRankingEntry {
  const GeneralRankingEntryModel({
    required super.userId,
    required super.name,
    required super.points,
    required super.leagueName,
  });

  factory GeneralRankingEntryModel.fromJson(Map<String, dynamic> json) {
    final userId = (json['user_id'] ?? json['userId']) as String;
    final name = json['name'] as String;
    final points = (json['points'] as num).toDouble();
    final leagueName = (json['league_name'] ?? json['leagueName']) as String;

    return GeneralRankingEntryModel(
      userId: userId,
      name: name,
      points: points,
      leagueName: leagueName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'points': points,
      'league_name': leagueName,
    };
  }
}
