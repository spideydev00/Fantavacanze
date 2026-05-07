import 'package:fantavacanze_official/core/entities/notification/entity/notification.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/league/data/datasources/local/local_data_source.dart';
import 'package:fantavacanze_official/features/league/data/datasources/remote/notification_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/domain/repository/notifications_repository.dart';
import 'package:fpdart/fpdart.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  NotificationsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, List<Notification>>> getNotifications(
      String leagueId) async {
    try {
      if (await connectionChecker.isConnected) {
        try {
          final remote = await remoteDataSource.getNotifications();
          await localDataSource.replaceNotificationsForLeague(leagueId, remote);
          return Right(remote);
        } on ServerException catch (e) {
          final cached =
              await localDataSource.getCachedNotificationsForLeague(leagueId);
          if (cached.isNotEmpty) return Right(cached);
          return Left(Failure(e.message));
        }
      }

      final cached =
          await localDataSource.getCachedNotificationsForLeague(leagueId);
      return Right(cached);
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
      String notificationId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      // Delete from server
      await remoteDataSource.deleteNotification(notificationId);

      // Delete from cache
      await localDataSource.deleteNotificationFromCache(notificationId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Either<Failure, Stream<Notification>> listenToNotification() {
    try {
      final stream = remoteDataSource.listenToNotification();
      return Right(stream);
    } on ServerException catch (e) {
      return Left(
          Failure('Errore nell\'ascolto delle notifiche: ${e.message}'));
    }
  }
}
