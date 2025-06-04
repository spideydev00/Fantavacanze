import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteNotificationParams {
  final String notificationId;

  DeleteNotificationParams({required this.notificationId});
}

class DeleteNotification implements Usecase<void, DeleteNotificationParams> {
  final LeagueRepository leagueRepository;

  DeleteNotification({required this.leagueRepository});

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) async {
    return await leagueRepository.deleteNotification(params.notificationId);
  }
}
