import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';

/// Sorts a list of leagues by creation date, newest first
List<League> sortLeaguesByDate(List<League> leagues) {
  final sortedLeagues = List<League>.from(leagues);
  sortedLeagues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sortedLeagues;
}

/// Sorts a list of memories by creation date, newest first
List<Memory> sortMemoriesByDate(List<Memory> memories) {
  final sortedMemories = List<Memory>.from(memories);
  sortedMemories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sortedMemories;
}
