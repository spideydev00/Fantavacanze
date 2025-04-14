import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    super.leagues,
  });

  factory DashboardDataModel.fromEntity(DashboardData data) {
    return DashboardDataModel(
      leagues: data.leagues,
    );
  }

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      leagues: json['leagues'] != null
          ? List<LeagueModel>.from(
              json['leagues'].map((league) => LeagueModel.fromJson(league)))
          : null,
    );
  }

  DashboardDataModel copyWith({
    User? user,
    List<League>? leagues,
  }) {
    return DashboardDataModel(
      leagues: leagues ?? this.leagues,
    );
  }
}
