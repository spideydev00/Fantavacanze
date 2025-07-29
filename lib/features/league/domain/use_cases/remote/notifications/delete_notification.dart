import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/notifications_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteNotificationParams {
  final String notificationId;

  DeleteNotificationParams({required this.notificationId});
}

class DeleteNotification implements Usecase<void, DeleteNotificationParams> {
  final NotificationsRepository notificationsRepository;

  DeleteNotification({required this.notificationsRepository});

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) async {
    return await notificationsRepository
        .deleteNotification(params.notificationId);
  }
}
