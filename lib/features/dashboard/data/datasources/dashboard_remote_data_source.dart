import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/dashboard/data/models/dashboard_data_model.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboardData();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final AppLeagueCubit appLeagueCubit;

  DashboardRemoteDataSourceImpl({
    required this.appLeagueCubit,
  });

  @override
  Future<DashboardDataModel> getDashboardData() async {
    try {
      final state = appLeagueCubit.state;

      //can add different state checks if needed
      if (state is AppLeagueExists) {
        return DashboardDataModel(
          leagues: state.leagues,
          //could have more data here...
        );
      }

      return DashboardDataModel(
        leagues: [],
        //could have more data here...
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
