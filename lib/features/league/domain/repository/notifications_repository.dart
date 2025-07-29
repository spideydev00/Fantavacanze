import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart';
import 'package:fpdart/fpdart.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<Notification>>> getNotifications();

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Either<Failure, Stream<Notification>> listenToNotification();
}
