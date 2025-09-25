import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/core/entities/notification/entity/notification.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/delete_notification.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/get_notifications.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/listen_to_notification.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotifications getNotifications;
  final DeleteNotification deleteNotification;
  final ListenToNotification listenToNotification;
  final NotificationCountCubit notificationCountCubit;

  // Stream subscription for notifications
  StreamSubscription<Notification>? _notificationSubscription;

  NotificationsBloc({
    required this.getNotifications,
    required this.deleteNotification,
    required this.listenToNotification,
    required this.notificationCountCubit,
  }) : super(const NotificationsInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<ListenToNotificationEvent>(_onListenToNotification);
  }

  // Handle getting notifications
  void _onGetNotifications(
    GetNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());

    final result = await getNotifications(NoParams());

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (notifications) {
        // Update notification count immediately when notifications are loaded
        notificationCountCubit.setCount(notifications.length);

        emit(NotificationsLoaded(notifications: notifications));
      },
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await deleteNotification(
      DeleteNotificationParams(notificationId: event.notificationId),
    );

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (_) {
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
