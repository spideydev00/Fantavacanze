import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fpdart/fpdart.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboardData();
}
