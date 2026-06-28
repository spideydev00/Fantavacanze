import 'package:fantavacanze_official/features/league/domain/entities/partner/general_ranking_entry.dart';

/// Ordina la classifica globale con gli spareggi: punti, bonus, |malus|, nome.
List<GeneralRankingEntry> sortGeneralRanking(
    List<GeneralRankingEntry> entries) {
  final sorted = List<GeneralRankingEntry>.from(entries);
  sorted.sort((a, b) {
    final byPoints = b.points.compareTo(a.points);
    if (byPoints != 0) return byPoints;

    final byBonus = b.bonusTotal.compareTo(a.bonusTotal);
    if (byBonus != 0) return byBonus;

    final byMalus = a.malusTotal.abs().compareTo(b.malusTotal.abs());
    if (byMalus != 0) return byMalus;

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return sorted;
}
