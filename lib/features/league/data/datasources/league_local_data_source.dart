import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

abstract interface class LeagueLocalDataSource {
  Future<void> cacheLeagues(List<LeagueModel> leagues);
  Future<List<LeagueModel>> getCachedLeagues();

  Future<void> cacheLeague(LeagueModel league);
  Future<LeagueModel?> getCachedLeague(String leagueId);
  Future<void> removeLeagueFromCache(String leagueId);

  Future<void> cacheRules(List<RuleModel> rules, String mode);
  Future<List<RuleModel>> getCachedRules(String mode);

  Future<void> clearCache();

  // Notes methods
  Future<List<NoteModel>> getNotes(String leagueId);
  Future<void> saveNote(String leagueId, NoteModel note);
  Future<void> deleteNote(String leagueId, String noteId);
}

class LeagueLocalDataSourceImpl implements LeagueLocalDataSource {
  final Box<Map<dynamic, dynamic>> leaguesBox;
  final Box<Map<dynamic, dynamic>> rulesBox;
  final Box<Map<dynamic, dynamic>> notesBox;

  LeagueLocalDataSourceImpl({
    required this.leaguesBox,
    required this.rulesBox,
    required this.notesBox,
  });

  @override
  Future<void> cacheLeagues(List<LeagueModel> leagues) async {
    try {
      final Map<String, dynamic> leaguesMap = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': leagues.map((league) => league.toJson()).toList(),
      };

      leaguesBox.write(() {
        leaguesBox.put('user_leagues', leaguesMap);
      });

      debugPrint("📦 Cached ${leagues.length} leagues");
    } catch (e) {
      throw CacheException(
          'Errore nel salvare le leghe in cache: ${e.toString()}');
    }
  }

  @override
  Future<List<LeagueModel>> getCachedLeagues() async {
    try {
      List<LeagueModel> leagues = [];

      leaguesBox.read(() {
        final leaguesData = leaguesBox.get('user_leagues');
        if (leaguesData != null) {
          final List<dynamic> leaguesList = leaguesData['data'] as List;
          leagues = leaguesList
              .map((league) =>
                  LeagueModel.fromJson(Map<String, dynamic>.from(league)))
              .toList();

          debugPrint("📤 Loaded ${leagues.length} leagues from cache)");
        } else {
          debugPrint("📤 No cached leagues found.");
        }
      });

      return leagues;
    } catch (e) {
      throw CacheException(
          'Errore nel recuperare le leghe dalla cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheLeague(LeagueModel league) async {
    try {
      final leagueData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': league.toJson(),
      };

      leaguesBox.write(() {
        leaguesBox.put(league.id, leagueData);
      });

      debugPrint("📦 Cached single league [${league.id}]");
    } catch (e) {
      throw CacheException(
          'Errore nel salvare la lega in cache: ${e.toString()}');
    }
  }

  @override
  Future<LeagueModel?> getCachedLeague(String leagueId) async {
    try {
      LeagueModel? league;

      leaguesBox.read(() {
        final leagueData = leaguesBox.get(leagueId);
        if (leagueData != null) {
          league = LeagueModel.fromJson(
              Map<String, dynamic>.from(leagueData['data']));
          debugPrint("📤 Loaded league [$leagueId] from cache)");
        } else {
          debugPrint("📤 League [$leagueId] not found in cache.");
        }
      });

      return league;
    } catch (e) {
      throw CacheException(
          'Errore nel recuperare la lega dalla cache: ${e.toString()}');
    }
  }

  @override
  Future<void> removeLeagueFromCache(String leagueId) async {
    try {
      leaguesBox.write(() {
        leaguesBox.delete(leagueId);

        final userLeaguesData = leaguesBox.get('user_leagues');
        if (userLeaguesData != null) {
          final List<dynamic> leaguesList = userLeaguesData['data'] as List;
          final updatedLeaguesList = leaguesList.where((leagueData) {
            final league =
                LeagueModel.fromJson(Map<String, dynamic>.from(leagueData));
            return league.id != leagueId;
          }).toList();

          final updatedUserLeaguesData = {
            'timestamp': DateTime.now().toIso8601String(),
            'data': updatedLeaguesList,
          };

          leaguesBox.put('user_leagues', updatedUserLeaguesData);

          debugPrint(
              "🗑️ Removed league [$leagueId] and updated user_leagues cache.");
        }
      });
    } catch (e) {
      throw CacheException(
          'Errore nel rimuovere la lega dalla cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheRules(List<RuleModel> rules, String mode) async {
    try {
      final rulesData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': rules.map((rule) => rule.toJson()).toList(),
      };

      rulesBox.write(() {
        rulesBox.put('rules_$mode', rulesData);
      });

      debugPrint("📦 Cached ${rules.length} rules for mode [$mode]");
    } catch (e) {
      throw CacheException(
          'Errore nel salvare le regole in cache: ${e.toString()}');
    }
  }

  @override
  Future<List<RuleModel>> getCachedRules(String mode) async {
    try {
      List<RuleModel> rules = [];

      rulesBox.read(() {
        final rulesData = rulesBox.get('rules_$mode');
        if (rulesData != null) {
          final List<dynamic> rulesList = rulesData['data'] as List;
          rules = rulesList
              .map(
                  (rule) => RuleModel.fromJson(Map<String, dynamic>.from(rule)))
              .toList();

          debugPrint(
              "📤 Loaded ${rules.length} rules for mode [$mode] from cache)");
        } else {
          debugPrint("📤 No cached rules found for mode [$mode].");
        }
      });

      return rules;
    } catch (e) {
      throw CacheException(
          'Errore nel recuperare le regole dalla cache: ${e.toString()}');
    }
  }

  @override
  Future<List<NoteModel>> getNotes(String leagueId) async {
    try {
      final List<NoteModel> notes = [];

      notesBox.read(() {
        final notesData = notesBox.get('notes');
        if (notesData != null) {
          final List<dynamic> notesList = notesData['data'] as List;
          notes.addAll(notesList
              .map(
                  (note) => NoteModel.fromJson(Map<String, dynamic>.from(note)))
              .where((note) => note.leagueId == leagueId) // Filter by leagueId
              .toList());

          debugPrint(
              "📤 Loaded ${notes.length} notes for league [$leagueId] from cache");
        } else {
          debugPrint("📤 No cached notes found.");
        }
      });

      return notes;
    } catch (e) {
      throw CacheException(
          'Error retrieving notes from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> saveNote(String leagueId, NoteModel note) async {
    try {
      // Get all existing notes
      List<NoteModel> allNotes = [];

      notesBox.read(() {
        final notesData = notesBox.get('notes');
        if (notesData != null) {
          final List<dynamic> notesList = notesData['data'] as List;
          allNotes = notesList
              .map(
                  (note) => NoteModel.fromJson(Map<String, dynamic>.from(note)))
              .toList();
        }
      });

      // Add the new note
      allNotes = [note, ...allNotes];

      final updatedNotesData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': allNotes.map((note) => note.toJson()).toList(),
      };

      notesBox.write(() {
        notesBox.put('notes', updatedNotesData);
      });

      debugPrint("📦 Saved note [${note.id}] for league [$leagueId]");
    } catch (e) {
      throw CacheException('Error saving note to cache: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNote(String leagueId, String noteId) async {
    try {
      // Get all existing notes
      List<NoteModel> allNotes = [];

      notesBox.read(() {
        final notesData = notesBox.get('notes');
        if (notesData != null) {
          final List<dynamic> notesList = notesData['data'] as List;
          allNotes = notesList
              .map(
                  (note) => NoteModel.fromJson(Map<String, dynamic>.from(note)))
              .toList();
        }
      });

      // Remove the note with the specified ID
      allNotes.removeWhere((note) => note.id == noteId);

      final updatedNotesData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': allNotes.map((note) => note.toJson()).toList(),
      };

      notesBox.write(() {
        notesBox.put('notes', updatedNotesData);
      });

      debugPrint("🗑️ Deleted note [$noteId] for league [$leagueId]");
    } catch (e) {
      throw CacheException('Error deleting note from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      leaguesBox.clear();
      rulesBox.clear();
      notesBox.clear();
      debugPrint("🧹 Cleared all league, rules, and notes cache");
    } catch (e) {
      throw CacheException('Error cleaning local cache: ${e.toString()}');
    }
  }
}
