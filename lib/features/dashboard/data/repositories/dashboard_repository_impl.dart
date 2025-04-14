import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:fantavacanze_official/features/dashboard/data/models/dashboard_data_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource dashboardRemoteDataSource;

  DashboardRepositoryImpl({
    required this.dashboardRemoteDataSource,
  });

  @override
  Future<Either<Failure, DashboardDataModel>> getDashboardData() async {
    try {
      final dashboardData = await dashboardRemoteDataSource.getDashboardData();

      return Right(dashboardData);
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
