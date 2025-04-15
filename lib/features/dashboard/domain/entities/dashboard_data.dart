import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';

class DashboardData extends Equatable {
  final List<League>? leagues;
  final League? selectedLeague;

  const DashboardData({
    this.leagues,
    this.selectedLeague,
  });

  @override
  List<Object?> get props => [leagues, selectedLeague];
}
