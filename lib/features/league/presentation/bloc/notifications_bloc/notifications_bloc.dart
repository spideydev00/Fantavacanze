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
  bool _isStartingNotificationListener = false;
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
    on<_NotificationStreamReceived>(_onNotificationStreamReceived);
    on<_NotificationStreamErrorOccurred>(_onNotificationStreamErrorOccurred);

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
    if (_notificationSubscription != null || _isStartingNotificationListener) {
      return;
    }

    _isStartingNotificationListener = true;
    try {
      final result = await listenToNotification(NoParams());

      result.fold(
        (failure) {
          emit(NotificationsError(message: failure.message));
        },
        (notificationStream) {
          _notificationSubscription = notificationStream.listen(
            (notification) => add(_NotificationStreamReceived(notification)),
            onError: (Object error, StackTrace stackTrace) {
              add(_NotificationStreamErrorOccurred(error.toString()));
            },
            onDone: () => _notificationSubscription = null,
          );
        },
      );
    } finally {
      _isStartingNotificationListener = false;
    }
  }

  void _onNotificationStreamReceived(
    _NotificationStreamReceived event,
    Emitter<NotificationsState> emit,
  ) {
    notificationCountCubit.increment();
    emit(NotificationReceived(notification: event.notification));
  }

  void _onNotificationStreamErrorOccurred(
    _NotificationStreamErrorOccurred event,
    Emitter<NotificationsState> emit,
  ) {
    emit(NotificationsError(message: event.message));
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
  Future<void> close() async {
    await _notificationSubscription?.cancel();
    await _leagueSubscription?.cancel();
    return super.close();
  }
}

final class _NotificationStreamReceived extends NotificationsEvent {
  const _NotificationStreamReceived(this.notification);

  final Notification notification;

  @override
  List<Object?> get props => [notification];
}

final class _NotificationStreamErrorOccurred extends NotificationsEvent {
  const _NotificationStreamErrorOccurred(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
