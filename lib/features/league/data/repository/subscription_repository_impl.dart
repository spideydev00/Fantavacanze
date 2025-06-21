import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/league/data/datasources/subscription_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/domain/entities/subscription.dart';
import 'package:fantavacanze_official/features/league/domain/repository/subscription_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, List<String>>> getProducts() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure('No internet connection. Please try again later.'));
      }

      final products = await remoteDataSource.getProducts();
      return right(products);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Subscription>> purchaseProduct(
      String productId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure('No internet connection. Please try again later.'));
      }

      final subscription = await remoteDataSource.purchaseProduct(productId);
      return right(subscription as Subscription);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Subscription?>> restorePurchases() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure('No internet connection. Please try again later.'));
      }

      final subscription = await remoteDataSource.restorePurchases();

      return right(subscription as Subscription?);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPremiumStatus() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure('No internet connection. Please try again later.'));
      }

      final isPremium = await remoteDataSource.checkPremiumStatus();
      return right(isPremium);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserPremiumStatus(User user) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure('No internet connection. Please try again later.'));
      }

      // Check premium status from RevenueCat
      final isPremium = await remoteDataSource.checkPremiumStatus();

      // Update user model
      final updatedUser = user.copyWith(isPremium: isPremium);

      return right(updatedUser);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
