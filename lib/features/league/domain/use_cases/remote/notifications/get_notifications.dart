import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart';
import 'package:fantavacanze_official/features/league/domain/repository/notifications_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetNotifications implements Usecase<List<Notification>, NoParams> {
  final NotificationsRepository notificationsRepository;

  GetNotifications({required this.notificationsRepository});

  @override
  Future<Either<Failure, List<Notification>>> call(NoParams params) async {
    return await notificationsRepository.getNotifications();
  }
}
