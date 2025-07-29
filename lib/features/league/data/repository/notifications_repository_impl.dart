import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/league/data/datasources/local/local_data_source.dart';
import 'package:fantavacanze_official/features/league/data/datasources/remote/notification_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/data/models/notification_model/notification/notification_model.dart';
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
  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    try {
      // Prima prova a prendere le notifiche dalla cache
      final cachedNotifications =
          await localDataSource.getCachedNotifications();

      // Esegui pulizia delle notifiche vecchie
      await localDataSource.cleanupOldNotifications();

      // Se ci sono notifiche nella cache, restituiscile
      if (cachedNotifications.isNotEmpty) {
        return Right(cachedNotifications);
      }

      // Ottieni le notifiche dal server
      final notifications = await remoteDataSource.getNotifications();

      // Salva le notifiche nella cache
      await localDataSource.cacheNotifications(notifications);

      return Right(notifications);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      // Update on the server
      await remoteDataSource.markAsRead(notificationId);

      // Update in cache
      await localDataSource.markNotificationAsRead(notificationId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
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
  Either<Failure, Stream<NotificationModel>> listenToNotification() {
    try {
      final stream = remoteDataSource.listenToNotification();

      stream.listen((notificationModel) async {
        // Salva direttamente nella cache
        await localDataSource.cacheNotification(notificationModel);
      });

      return Right(stream);
    } on ServerException catch (e) {
      return Left(
          Failure('Errore nell\'ascolto delle notifiche: ${e.message}'));
    }
  }
}
