import 'package:fantavacanze_official/features/league/data/models/notification_model/daily_challenge_notification/daily_challenge_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model/rule_model.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model/note_model.dart';
import 'package:fantavacanze_official/features/league/data/models/daily_challenge_model/daily_challenge_model.dart';
import 'package:fantavacanze_official/features/league/data/models/notification_model/notification/notification_model.dart';

abstract interface class LeagueLocalDataSource {
  // =====================================================================
  // LEAGUE OPERATIONS
  // =====================================================================
  Future<void> cacheLeagues(List<LeagueModel> leagues);
  Future<List<LeagueModel>> getCachedLeagues();
  Future<void> cacheLeague(LeagueModel league);
  Future<LeagueModel?> getCachedLeague(String leagueId);
  Future<void> removeLeagueFromCache(String leagueId);

  // =====================================================================
  // RULE OPERATIONS
  // =====================================================================
  // Future<void> cacheRules(List<RuleModel> rules, String mode);
  // Future<List<RuleModel>> getCachedRules(String mode);

  // =====================================================================
  // DAILY CHALLENGE OPERATIONS
  // =====================================================================
  Future<void> cacheDailyChallenges(
      List<DailyChallengeModel> challenges, String leagueId);
  Future<List<DailyChallengeModel>> getCachedDailyChallenges(
    String leagueId,
  );
  Future<void> updateCachedChallenge(
      String challengeId, String leagueId, bool isRefreshed);
  Future<String> findLeagueIdForChallenge(String challengeId);

  // =====================================================================
  // NOTE OPERATIONS
  // =====================================================================
  Future<List<NoteModel>> getNotes(String leagueId);
  Future<void> saveNote(NoteModel note, String leagueId);
  Future<void> deleteNote(String noteId, String leagueId);

  // =====================================================================
  // NOTIFICATION OPERATIONS
  // =====================================================================
  Future<void> cacheNotification(NotificationModel notification);
  Future<void> cacheNotifications(List<NotificationModel> notifications);
  Future<List<NotificationModel>> getCachedNotifications();
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> deleteNotificationFromCache(String notificationId);
  Future<void> cleanupOldNotifications();
  Future<void> updateNotification(NotificationModel notification);

  // =====================================================================
  // CACHE MANAGEMENT
  // =====================================================================
  Future<void> clearCache();
}

class LeagueLocalDataSourceImpl implements LeagueLocalDataSource {
  final Box<LeagueModel> leaguesBox;
  final Box<List<RuleModel>> rulesBox;
  final Box<NoteModel> notesBox;
  final Box<DailyChallengeModel> challengesBox;
  final Box<NotificationModel> notificationsBox;

  LeagueLocalDataSourceImpl({
    required this.leaguesBox,
    required this.rulesBox,
    required this.notesBox,
    required this.challengesBox,
    required this.notificationsBox,
  });

  // =====================================================================
  // LEAGUE OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<void> cacheLeagues(List<LeagueModel> leagues) async {
    try {
      for (final league in leagues) {
        await leaguesBox.put(league.id, league);
      }
    } catch (e) {
      throw CacheException('Errore nel salvare le leghe: $e');
    }
  }

  @override
  Future<List<LeagueModel>> getCachedLeagues() async {
    try {
      final leagues = leaguesBox.values.toList();

      if (leagues.isEmpty) {
        return [];
      }

      return leagues;
    } catch (e) {
      throw CacheException('Errore nel recuperare le leghe: $e');
    }
  }

  @override
  Future<void> cacheLeague(LeagueModel league) async {
    try {
      await leaguesBox.put(league.id, league);
    } catch (e) {
      throw CacheException('Errore nel salvare la lega: $e');
    }
  }

  @override
  Future<LeagueModel?> getCachedLeague(String leagueId) async {
    try {
      final league = leaguesBox.get(leagueId);

      if (league == null) {
        return null;
      }

      return league;
    } catch (e) {
      throw CacheException('Errore nel recuperare la lega: $e');
    }
  }

  @override
  Future<void> removeLeagueFromCache(String leagueId) async {
    try {
      await leaguesBox.delete(leagueId);

      debugPrint("🗑️ Rimossa lega [$leagueId] dalla cache");
    } catch (e) {
      throw CacheException('Errore nel rimuovere la lega: $e');
    }
  }

  // =====================================================================
  // RULE OPERATIONS IMPLEMENTATION
  // =====================================================================

  // @override
  // Future<void> cacheRules(List<RuleModel> rules, String mode) async {
  //   try {
  //     rulesBox.put("${mode}_rules", rules);
  //
  //     debugPrint("📦${rules.length} regole cachate");
  //   } catch (e) {
  //     throw CacheException('Errore nel salvare le regole: $e');
  //   }
  // }

  // @override
  // Future<List<RuleModel>> getCachedRules(String mode) async {
  //   try {
  //     final rules = rulesBox.get("${mode}_rules") ?? [];
  //
  //     if (rules.isEmpty) {
  //       return [];
  //     }
  //
  //     debugPrint("Caricate ${rules.length} regole");
  //
  //     return rules;
  //   } catch (e) {
  //     throw CacheException('Errore nel recuperare le regole: $e');
  //   }
  // }

  // =====================================================================
  // NOTE OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<List<NoteModel>> getNotes(String leagueId) async {
    try {
      final notes =
          notesBox.values.where((note) => note.leagueId == leagueId).toList();

      debugPrint("📤 Caricate ${notes.length} note per la lega $leagueId");

      return notes;
    } catch (e) {
      throw CacheException('Errore nel recuperare le note: $e');
    }
  }

  @override
  Future<void> saveNote(NoteModel note, String leagueId) async {
    try {
      final key = "${leagueId}_${note.id}";

      await notesBox.put(key, note);

      debugPrint("📦 Nota salvata [${note.id}] nella lega $leagueId");
    } catch (e) {
      throw CacheException('Errore nel salvare la nota: $e');
    }
  }

  @override
  Future<void> deleteNote(String noteId, String leagueId) async {
    try {
      final key = "${leagueId}_$noteId";

      await notesBox.delete(key);

      debugPrint("🗑️ Eliminata la nota [$noteId]");
    } catch (e) {
      throw CacheException('Errore nel cancellare la nota: $e');
    }
  }

  // =====================================================================
  // DAILY CHALLENGE OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<void> cacheDailyChallenges(
    List<DailyChallengeModel> challenges,
    String leagueId,
  ) async {
    try {
      for (final challenge in challenges) {
        final key = "${leagueId}_${challenge.id}";

        await challengesBox.put(key, challenge);
      }

      debugPrint(
          "📦 Cachate ${challenges.length} daily challenges nella lega $leagueId");
    } catch (e) {
      throw CacheException('Errore nel salvare le sfide: $e');
    }
  }

  @override
  Future<List<DailyChallengeModel>> getCachedDailyChallenges(
    String leagueId,
  ) async {
    try {
      List<DailyChallengeModel> challenges = [];

      challengesBox.values
          .where((challenge) => challenge.leagueId == leagueId)
          .forEach((challenge) {
        challenges.add(challenge);
      });

      return challenges;
    } catch (e) {
      throw CacheException('Errore nel recuperare le sfide: $e');
    }
  }

  @override
  Future<void> updateCachedChallenge(
      String challengeId, String leagueId, bool isRefreshed) async {
    try {
      final challenges = await getCachedDailyChallenges(leagueId);

      final updatedChallenges = challenges.map((challenge) {
        if (challenge.id == challengeId) {
          return challenge.copyWith(
            isRefreshed: isRefreshed,
            refreshedAt: DateTime.now(),
          );
        }
        return challenge;
      }).toList();

      await cacheDailyChallenges(updatedChallenges, leagueId);

      debugPrint(
          "📦 Aggiornata la challenge $challengeId nella cache per la lega $leagueId");
    } catch (e) {
      throw CacheException('Errore nell\'aggiornare la sfida: $e');
    }
  }

  @override
  Future<String> findLeagueIdForChallenge(String challengeId) async {
    try {
      // Get all cached leagues
      final leagues = getCachedLeagues();

      // Check each league's challenges
      for (final league in await leagues) {
        final challenges = await getCachedDailyChallenges(league.id);
        if (challenges.any((c) => c.id == challengeId)) {
          return league.id;
        }
      }

      debugPrint("⚠️ Challenge non trovata in nessuna delle leghe cachate.");
      return '';
    } catch (e) {
      debugPrint("⚠️ Errore nel trovare challenge nella lega: $e");
      return '';
    }
  }

  // =====================================================================
  // NOTIFICATION OPERATIONS IMPLEMENTATION
  // =====================================================================

  @override
  Future<void> cacheNotification(NotificationModel notification) async {
    try {
      await notificationsBox.put(notification.id, notification);

      debugPrint("📦 Notifica cachata [${notification.id}]");
    } catch (e) {
      throw CacheException('Errore nel salvare la notifica: $e');
    }
  }

  @override
  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    try {
      for (final notification in notifications) {
        // Controlliamo se la notifica esiste già
        final existingNotification = notificationsBox.get(notification.id);

        // Se non esiste, la salviamo
        if (existingNotification == null) {
          await notificationsBox.put(notification.id, notification);
        }
      }

      debugPrint("📦 Cachate ${notifications.length} notifiche");
    } catch (e) {
      throw CacheException('Errore nel cachare le notifiche: $e');
    }
  }

  // Modifica il metodo getCachedNotifications per gestire il numero massimo
  @override
  Future<List<NotificationModel>> getCachedNotifications() async {
    try {
      final notifications = notificationsBox.values.toList();

      // Sort by creation date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Limita il numero di notifiche restituite
      const int maxNotifications = 50;
      final result = notifications.length > maxNotifications
          ? notifications.sublist(0, maxNotifications)
          : notifications;

      debugPrint("📤 Caricate ${result.length} notifiche dalla cache");

      return result;
    } catch (e) {
      throw CacheException('Errore nel recuperare le notifiche: $e');
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final notification = notificationsBox.get(notificationId);

      if (notification != null) {
        Map<String, dynamic> json = notification.toJson();
        json['is_read'] = true;

        NotificationModel updatedNotification;

        // Check if it's a DailyChallengeNotification or base Notification
        if (json.containsKey('challenge_id')) {
          updatedNotification = DailyChallengeNotificationModel.fromJson(json);
        } else {
          updatedNotification = NotificationModel.fromJson(json);
        }

        await notificationsBox.put(notificationId, updatedNotification);
      }
    } catch (e) {
      throw CacheException('Errore nel marcare la notifica come letta: $e');
    }
  }

  // Modifica deleteNotificationFromCache per eliminare solo se necessario
  @override
  Future<void> deleteNotificationFromCache(String notificationId) async {
    try {
      final notification = notificationsBox.get(notificationId);

      // Elimina solo se è una notifica di tipo daily_challenge
      if (notification != null) {
        if (notification.type == 'daily_challenge') {
          await notificationsBox.delete(notificationId);
          debugPrint(
              "🗑️ Notifica sfida [$notificationId] eliminata dalla cache");
        } else {
          // Per altre notifiche, lasciamo nella cache ma aggiorniamo isRead
          final updatedNotification = NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            createdAt: notification.createdAt,
            isRead: true,
            type: notification.type,
            leagueId: notification.leagueId,
          );
          await notificationsBox.put(notificationId, updatedNotification);
          debugPrint(
              "📝 Notifica generica [$notificationId] segnata come letta nella cache");
        }
      }
    } catch (e) {
      throw CacheException('Errore nell\'eliminare la notifica: $e');
    }
  }

  @override
  Future<void> cleanupOldNotifications() async {
    try {
      final notifications = notificationsBox.values.toList();

      const int maxCacheNotifications = 100;
      if (notifications.length <= maxCacheNotifications) return;

      // Ordina per data (più vecchie prima)
      notifications.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Prendi quelle da eliminare
      final toDelete = notifications.sublist(
          0, notifications.length - maxCacheNotifications);

      // Elimina le notifiche più vecchie
      for (final notification in toDelete) {
        await notificationsBox.delete(notification.id);
      }

      debugPrint(
          "🧹 Eliminate ${toDelete.length} notifiche vecchie dalla cache");
    } catch (e) {
      debugPrint("⚠️ Errore nella pulizia delle vecchie notifiche: $e");
    }
  }

  @override
  Future<void> updateNotification(NotificationModel notification) async {
    try {
      await notificationsBox.put(notification.id, notification);

      debugPrint("🔄 Notifica [${notification.id}] aggiornata nella cache");
    } catch (e) {
      throw CacheException('Errore nell\'aggiornare la notifica: $e');
    }
  }

  // =====================================================================
  // CACHE MANAGEMENT IMPLEMENTATION
  // =====================================================================

  @override
  Future<void> clearCache() async {
    try {
      await leaguesBox.clear();
      await rulesBox.clear();
      await notesBox.clear();
      await challengesBox.clear();
      await notificationsBox.clear();

      debugPrint("🧹Tutte le cache Hive sono state svuotate");
    } catch (e) {
      throw CacheException('Errore nel pulire la cache: $e');
    }
  }
}
