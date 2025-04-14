import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fantavacanze_official/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardData implements Usecase<DashboardData, NoParams> {
  final DashboardRepository repository;

  GetDashboardData(this.repository);

  @override
  Future<Either<Failure, DashboardData>> call(NoParams params) async {
    return await repository.getDashboardData();
  }
}
