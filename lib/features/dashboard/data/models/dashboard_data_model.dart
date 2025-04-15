import 'package:fantavacanze_official/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    super.leagues,
    super.selectedLeague,
  });

  factory DashboardDataModel.fromEntity(DashboardData data) {
    return DashboardDataModel(
      leagues: data.leagues,
      selectedLeague: data.selectedLeague,
    );
  }

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      leagues: json['leagues'] != null
          ? List<LeagueModel>.from(
              json['leagues'].map((league) => LeagueModel.fromJson(league)))
          : null,
      selectedLeague: json['selectedLeague'] != null
          ? LeagueModel.fromJson(json['selectedLeague'])
          : null,
    );
  }

  DashboardDataModel copyWith({
    List<League>? leagues,
    League? selectedLeague,
  }) {
    return DashboardDataModel(
      leagues: leagues ?? this.leagues,
      selectedLeague: selectedLeague ?? this.selectedLeague,
    );
  }
}
