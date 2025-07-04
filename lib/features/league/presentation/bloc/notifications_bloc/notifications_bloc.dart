import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge_notification.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/delete_notification.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/get_notifications.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/listen_to_notification.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/mark_notification_as_read.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotifications getNotifications;
  final MarkNotificationAsRead markNotificationAsRead;
  final DeleteNotification deleteNotification;
  final ListenToNotification listenToNotification;
  final NotificationCountCubit notificationCountCubit;

  // Stream subscription for notifications
  StreamSubscription<Notification>? _notificationSubscription;

  NotificationsBloc({
    required this.getNotifications,
    required this.markNotificationAsRead,
    required this.deleteNotification,
    required this.listenToNotification,
    required this.notificationCountCubit,
  }) : super(const NotificationsInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<ListenToNotificationEvent>(_onListenToNotification);
  }

  Future<void> _onGetNotifications(
    GetNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());

    final result = await getNotifications(NoParams());

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (notifications) {
        // Count only regular (non-challenge) unread notifications
        final unreadCount = notifications
            .where((n) => !n.isRead && n is! DailyChallengeNotification)
            .length;

        // Update notification count in the cubit
        notificationCountCubit.setCount(unreadCount);

        emit(NotificationsLoaded(notifications: notifications));
      },
    );
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    // Do not emit loading state here to avoid UI flicker
    final currentState = state;

    final result = await markNotificationAsRead(
      MarkNotificationAsReadParams(notificationId: event.notificationId),
    );

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (_) {
        // Only decrement notification count for regular notifications
        if (currentState is NotificationsLoaded) {
          final notification = currentState.notifications
              .firstWhere((n) => n.id == event.notificationId);

          if (notification is! DailyChallengeNotification &&
              !notification.isRead) {
            notificationCountCubit.decrement();
          }
        }

        emit(NotificationActionSuccess(
          action: 'mark_as_read',
          notificationId: event.notificationId,
        ));

        // Refresh notifications to show updated read status
        add(GetNotificationsEvent());
      },
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    // Store notification type before deletion for correct count update
    bool isDailyChallengeNotification = false;
    bool isUnread = false;

    if (currentState is NotificationsLoaded) {
      final notificationToDelete = currentState.notifications.firstWhere(
          (n) => n.id == event.notificationId,
          orElse: () => throw Exception("Notification not found"));

      isDailyChallengeNotification =
          notificationToDelete is DailyChallengeNotification;
      isUnread = !notificationToDelete.isRead;
    }

    final result = await deleteNotification(
      DeleteNotificationParams(notificationId: event.notificationId),
    );

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (_) {
        // Only decrement count for non-challenge unread notifications
        if (isUnread && !isDailyChallengeNotification) {
          notificationCountCubit.decrement();
        }

        emit(NotificationActionSuccess(
          action: 'delete',
          notificationId: event.notificationId,
        ));

        // Refresh the notifications list
        add(GetNotificationsEvent());
      },
    );
  }

  Future<void> _onListenToNotification(
    ListenToNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    _notificationSubscription?.cancel();

    final result = await listenToNotification(NoParams());

    result.fold(
      (failure) {
        emit(NotificationsError(message: failure.message));
      },
      (notificationStream) {
        emit.forEach<Notification>(
          notificationStream,
          onData: (notification) {
            // Increment notification count
            notificationCountCubit.increment();
            // Return the notification state that will be emitted
            return NotificationReceived(notification: notification);
          },
          onError: (error, stackTrace) => NotificationsError(
            message: error.toString(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
