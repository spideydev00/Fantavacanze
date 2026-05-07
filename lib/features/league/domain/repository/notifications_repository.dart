import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/entities/notification/entity/notification.dart';
import 'package:fpdart/fpdart.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<Notification>>> getNotifications(String leagueId);
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Either<Failure, Stream<Notification>> listenToNotification();
}
