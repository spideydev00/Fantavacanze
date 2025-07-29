import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/notifications_repository.dart';
import 'package:fpdart/fpdart.dart';

class MarkNotificationAsReadParams {
  final String notificationId;

  MarkNotificationAsReadParams({required this.notificationId});
}

class MarkNotificationAsRead
    implements Usecase<void, MarkNotificationAsReadParams> {
  final NotificationsRepository notificationsRepository;

  MarkNotificationAsRead({required this.notificationsRepository});

  @override
  Future<Either<Failure, void>> call(
      MarkNotificationAsReadParams params) async {
    return await notificationsRepository.markAsRead(params.notificationId);
  }
}
