import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/notification_model/daily_challenge_notification/daily_challenge_notification_model.dart';
import 'package:fantavacanze_official/features/league/data/models/notification_model/notification/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class NotificationRemoteDataSource {
  Stream<NotificationModel> listenToNotification();

  Future<List<NotificationModel>> getNotifications();

  Future<void> markAsRead(String notificationId);

  Future<void> deleteNotification(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabaseClient;
  final AppUserCubit appUserCubit;
  final Uuid uuid = const Uuid();

  final _notificationModelController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get notificationModelStream =>
      _notificationModelController.stream;

  void initNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Converti direttamente in NotificationModel
        convertRemoteNotificationToModel(message.notification!, message)
            .then((notificationModel) {
          if (notificationModel != null) {
            _notificationModelController.add(notificationModel);
            debugPrint('📨 Notifica convertita: ${notificationModel.title}');
          }
        });
      }
    });
  }

  NotificationRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.appUserCubit,
  }) {
    initNotificationListener();
  }

  /// Extracts a clean error message from various exception types
  String _extractErrorMessage(Object e) {
    if (e is ServerException) return e.message;
    if (e is PostgrestException) return e.message;
    if (e is TimeoutException) return e.message ?? 'Operazione scaduta';
    return e.toString();
  }

  /// Wraps database operations to handle exceptions uniformly
  Future<T> _tryDatabaseOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      debugPrint('❌ Errore nella comunicazione col database: $e');
      throw ServerException(_extractErrorMessage(e));
    }
  }

  /// Gets the current user ID from cache or cubit
  String? _getCurrentUserId() {
    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      return state.user.id;
    }
    return null;
  }

  /// Checks authentication and returns user ID or throws exception
  String _checkAuthentication() {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      throw ServerException('Utente non autenticato');
    }
    return currentUserId;
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    return _tryDatabaseOperation(() async {
      final userId = _checkAuthentication();

      // Use the updated RPC function
      final response = await supabaseClient.rpc(
        'get_user_notifications',
        params: {'p_user_id': userId},
      );

      // The response now contains objects with a "notification" field
      final List<dynamic> notificationsWithDate = response as List<dynamic>;

      // Extract just the notification objects
      final notifications = notificationsWithDate.map((item) {
        final json = item['notification'];

        if (json['type'] == 'daily_challenge') {
          return DailyChallengeNotificationModel.fromJson(json);
        } else {
          return NotificationModel.fromJson(json);
        }
      }).toList();

      return notifications;
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    return _tryDatabaseOperation(() async {
      await supabaseClient.rpc(
        'mark_notification_as_read',
        params: {'p_notification_id': notificationId},
      );
    });
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    return _tryDatabaseOperation(
      () async {
        // Delete from standard notifications table
        await supabaseClient
            .from('notifications')
            .delete()
            .eq('id', notificationId);

        // Delete from daily challenge notifications table
        await supabaseClient
            .from('daily_challenges_notifications')
            .delete()
            .eq('id', notificationId);
      },
    );
  }

  @override
  Stream<NotificationModel> listenToNotification() {
    try {
      return notificationModelStream;
    } catch (e) {
      throw ServerException(
          'Errore nell\'ascolto delle notifiche: ${_extractErrorMessage(e)}');
    }
  }

  Future<NotificationModel?> convertRemoteNotificationToModel(
    RemoteNotification notification,
    RemoteMessage message,
  ) async {
    try {
      final data = message.data;
      if (data.isEmpty) return null;

      // Ottieni i dati dal payload FCM o usa valori di default
      final id = data['id'] ?? uuid.v4();
      final title = data['title'] ?? notification.title ?? 'Nuova notifica';
      final messageText = data['message'] ?? notification.body ?? '';
      final type = data['type'] ?? 'generic';
      final userId = data['user_id'] ?? _getCurrentUserId() ?? '';
      final leagueId = data['league_id'] ?? '';
      final createdAt = data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now();
      final isRead = data['is_read'] == 'true';

      // Parsing di target_user_ids
      List<String> targetUserIds = [];
      if (data['target_user_ids'] != null) {
        final rawIds = data['target_user_ids'].toString();
        targetUserIds = rawIds.split(',').where((id) => id.isNotEmpty).toList();
      }

      // Crea il modello appropriato in base al tipo
      if (type == 'daily_challenge') {
        return DailyChallengeNotificationModel(
          id: id,
          title: title,
          message: messageText,
          createdAt: createdAt,
          isRead: isRead,
          type: type,
          userId: userId,
          leagueId: leagueId,
          challengeId: data['challenge_id'] ?? '',
          challengeName: data['challenge_name'] ?? '',
          challengePoints:
              double.tryParse(data['challenge_points'] ?? '0') ?? 0.0,
          targetUserIds: targetUserIds,
        );
      } else {
        // Notifica generica
        return NotificationModel(
          id: id,
          title: title,
          message: messageText,
          createdAt: createdAt,
          isRead: isRead,
          type: type,
          leagueId: leagueId,
        );
      }
    } catch (e) {
      debugPrint("⚠️ Errore nella conversione della notifica: $e");
      return null;
    }
  }
}
