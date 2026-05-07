import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/core/entities/notification/entity/notification.dart';
import 'package:fantavacanze_official/features/league/domain/repository/notifications_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetNotificationsParams {
  final String leagueId;

  const GetNotificationsParams({required this.leagueId});
}

class GetNotifications
    implements Usecase<List<Notification>, GetNotificationsParams> {
  final NotificationsRepository notificationsRepository;

  GetNotifications({required this.notificationsRepository});

  @override
  Future<Either<Failure, List<Notification>>> call(
    GetNotificationsParams params,
  ) async {
    return await notificationsRepository.getNotifications(params.leagueId);
  }
}
