import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/dashboard/data/models/dashboard_data_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboardData();
  Future<DashboardDataModel> getDashboardDataForLeague(League league);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final AppLeagueCubit appLeagueCubit;

  DashboardRemoteDataSourceImpl({
    required this.appLeagueCubit,
  });

  @override
  Future<DashboardDataModel> getDashboardData() async {
    try {
      final leagueState = appLeagueCubit.state;

      if (leagueState is AppLeagueExists) {
        return DashboardDataModel(
          leagues: leagueState.leagues,
          selectedLeague: leagueState.selectedLeague,
        );
      }

      return const DashboardDataModel(
        leagues: [],
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DashboardDataModel> getDashboardDataForLeague(League league) async {
    try {
      final leagueState = appLeagueCubit.state;

      if (leagueState is AppLeagueExists) {
        // Aggiorna la lega selezionata
        appLeagueCubit.selectLeague(league);

        return DashboardDataModel(
          leagues: leagueState.leagues,
          selectedLeague: league,
        );
      }

      return DashboardDataModel(
        leagues: [],
        selectedLeague: league,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
