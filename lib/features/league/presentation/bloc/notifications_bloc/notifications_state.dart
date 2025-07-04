import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<Notification> notifications;

  const NotificationsLoaded({
    required this.notifications,
  });

  @override
  List<Object?> get props => [notifications];
}

class NotificationActionSuccess extends NotificationsState {
  final String action;
  final String? notificationId;

  const NotificationActionSuccess({
    required this.action,
    this.notificationId,
  });

  @override
  List<Object?> get props => [action, notificationId];
}

class NotificationReceived extends NotificationsState {
  final Notification notification;

  const NotificationReceived({
    required this.notification,
  });

  @override
  List<Object?> get props => [notification];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});

  @override
  List<Object?> get props => [message];
}
