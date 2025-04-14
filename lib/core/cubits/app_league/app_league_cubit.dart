import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_user_leagues.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_league_state.dart';

class AppLeagueCubit extends Cubit<AppLeagueState> {
  final GetUserLeagues _getUserLeagues;

  AppLeagueCubit({required GetUserLeagues getUserLeagues})
      : _getUserLeagues = getUserLeagues,
        super(AppLeagueInitial());

  Future<void> getUserLeagues() async {
    final res = await _getUserLeagues.call(NoParams());

    res.fold(
      (l) => emit(
        AppLeagueInitial(),
      ),
      (r) => updateLeagues(r),
    );
  }

  void updateLeagues(List<League>? leagues) {
    if (leagues == null || leagues.isEmpty) {
      emit(AppLeagueInitial());
    } else {
      emit(
        AppLeagueExists(leagues: leagues),
      );
    }
  }
}
