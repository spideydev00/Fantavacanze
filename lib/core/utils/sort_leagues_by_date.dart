import 'package:fantavacanze_official/features/league/domain/entities/league.dart';

List<League> sortLeaguesByDate(List<League> leagues) {
  final sortedLeagues = List<League>.from(leagues);
  sortedLeagues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sortedLeagues;
}
