import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart';
import 'package:fantavacanze_official/features/league/domain/repository/notifications_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListenToNotification implements Usecase<Stream<Notification>, NoParams> {
  final NotificationsRepository notificationsRepository;

  ListenToNotification({required this.notificationsRepository});

  @override
  Future<Either<Failure, Stream<Notification>>> call(NoParams params) async {
    return notificationsRepository.listenToNotification();
  }
}
