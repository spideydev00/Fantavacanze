import 'package:fantavacanze_official/features/league/domain/entities/subscription.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';

abstract interface class SubscriptionRepository {
  Future<Either<Failure, List<String>>> getProducts();
  Future<Either<Failure, Subscription>> purchaseProduct(String productId);
  Future<Either<Failure, Subscription?>> restorePurchases();
  Future<Either<Failure, bool>> checkPremiumStatus();
  Future<Either<Failure, User>> updateUserPremiumStatus(User user);
}
