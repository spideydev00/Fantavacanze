import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class GetNotificationsEvent extends NotificationsEvent {}

class MarkNotificationAsReadEvent extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsReadEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class DeleteNotificationEvent extends NotificationsEvent {
  final String notificationId;

  const DeleteNotificationEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class ListenToNotificationEvent extends NotificationsEvent {}
