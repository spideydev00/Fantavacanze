import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fpdart/fpdart.dart';

class ListenToNotification
    implements Usecase<Stream<RemoteNotification>, NoParams> {
  final LeagueRepository leagueRepository;

  ListenToNotification({required this.leagueRepository});

  @override
  Future<Either<Failure, Stream<RemoteNotification>>> call(
      NoParams params) async {
    return leagueRepository.listenToNotification();
  }
}
