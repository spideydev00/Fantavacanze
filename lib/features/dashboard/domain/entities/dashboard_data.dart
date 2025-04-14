import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';

class DashboardData extends Equatable {
  final List<League>? leagues;

  const DashboardData({
    this.leagues,
  });

  @override
  List<Object?> get props => [leagues];
}
