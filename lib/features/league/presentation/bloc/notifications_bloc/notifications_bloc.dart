import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
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
  final AppLeagueCubit appLeagueCubit;

  // Stream subscription for notifications
  StreamSubscription<Notification>? _notificationSubscription;
  StreamSubscription<AppLeagueState>? _leagueSubscription;
  String? _lastLeagueId;

  NotificationsBloc({
    required this.getNotifications,
    required this.deleteNotification,
    required this.listenToNotification,
    required this.notificationCountCubit,
    required this.appLeagueCubit,
  }) : super(const NotificationsInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<ListenToNotificationEvent>(_onListenToNotification);
    on<ResetNotificationsEvent>(_onResetNotifications);

    _leagueSubscription = appLeagueCubit.stream.listen(_onLeagueStateChanged);
  }

  // Handle getting notifications
  void _onGetNotifications(
    GetNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final leagueState = appLeagueCubit.state;
    if (leagueState is! AppLeagueExists) {
      notificationCountCubit.reset();
      emit(const NotificationsInitial());
      return;
    }

    emit(NotificationsLoading());

    final leagueId = leagueState.selectedLeague.id;
    final result = await getNotifications(
      GetNotificationsParams(leagueId: leagueId),
    );

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (notifications) {
        // Update notification count immediately when notifications are loaded
        notificationCountCubit.setCount(notifications.length);

        emit(NotificationsLoaded(notifications: notifications));
      },
    );
  }

  void _onResetNotifications(
    ResetNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) {
    notificationCountCubit.reset();
    emit(const NotificationsInitial());
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
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

        notificationCountCubit.decrement();

        if (currentState is NotificationsLoaded) {
          final updatedNotifications = currentState.notifications
              .where((notification) => notification.id != event.notificationId)
              .toList();

          emit(NotificationsLoaded(notifications: updatedNotifications));
        }
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

  void _onLeagueStateChanged(AppLeagueState leagueState) {
    if (leagueState is AppLeagueExists) {
      final leagueId = leagueState.selectedLeague.id;
      if (_lastLeagueId == leagueId) {
        return;
      }
      _lastLeagueId = leagueId;
      add(GetNotificationsEvent());
    } else {
      _lastLeagueId = null;
      add(const ResetNotificationsEvent());
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    _leagueSubscription?.cancel();
    return super.close();
  }
}
