import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fpdart/fpdart.dart';

class MarkNotificationAsReadParams {
  final String notificationId;

  MarkNotificationAsReadParams({required this.notificationId});
}

class MarkNotificationAsRead
    implements Usecase<void, MarkNotificationAsReadParams> {
  final LeagueRepository leagueRepository;

  MarkNotificationAsRead({required this.leagueRepository});

  @override
  Future<Either<Failure, void>> call(
      MarkNotificationAsReadParams params) async {
    return await leagueRepository.markAsRead(params.notificationId);
  }
}
