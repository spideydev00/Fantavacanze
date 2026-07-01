import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/events/add_event.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/events/remove_event.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/add_administrators.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/create_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/delete_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/exit_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/get_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/join_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/remove_participants.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/search_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/update_league_info.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/update_team_logo.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/update_team_name.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/upload_media.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/upload_team_logo.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/memory/add_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/memory/remove_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notes/delete_note.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notes/get_notes.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notes/save_note.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/rules/add_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/rules/delete_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/rules/update_rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/partner_fixtures.dart';

class MockGetLeague extends Mock implements GetLeague {}

class MockAppLeagueCubit extends Mock implements AppLeagueCubit {}

class MockAppUserCubit extends Mock implements AppUserCubit {}

class FakeCreateLeague extends Fake implements CreateLeague {}

class FakeDeleteLeague extends Fake implements DeleteLeague {}

class FakeJoinLeague extends Fake implements JoinLeague {}

class FakeExitLeague extends Fake implements ExitLeague {}

class FakeUpdateLeagueInfo extends Fake implements UpdateLeagueInfo {}

class FakeUpdateTeamName extends Fake implements UpdateTeamName {}

class FakeAddAdministrators extends Fake implements AddAdministrators {}

class FakeRemoveParticipants extends Fake implements RemoveParticipants {}

class FakeAddEvent extends Fake implements AddEvent {}

class FakeRemoveEvent extends Fake implements RemoveEvent {}

class FakeAddMemory extends Fake implements AddMemory {}

class FakeRemoveMemory extends Fake implements RemoveMemory {}

class FakeUpdateRule extends Fake implements UpdateRule {}

class FakeDeleteRule extends Fake implements DeleteRule {}

class FakeAddRule extends Fake implements AddRule {}

class FakeSearchLeague extends Fake implements SearchLeague {}

class FakeGetNotes extends Fake implements GetNotes {}

class FakeSaveNote extends Fake implements SaveNote {}

class FakeDeleteNote extends Fake implements DeleteNote {}

class FakeUploadMedia extends Fake implements UploadMedia {}

class FakeUploadTeamLogo extends Fake implements UploadTeamLogo {}

class FakeUpdateTeamLogo extends Fake implements UpdateTeamLogo {}

class FakeGetLeagueParams extends Fake implements GetLeagueParams {}

class FakeLeague extends Fake implements League {}

void main() {
  late MockGetLeague getLeague;
  late MockAppLeagueCubit appLeagueCubit;
  late MockAppUserCubit appUserCubit;

  setUpAll(() {
    registerFallbackValue(FakeGetLeagueParams());
    registerFallbackValue(FakeLeague());
  });

  setUp(() {
    getLeague = MockGetLeague();
    appLeagueCubit = MockAppLeagueCubit();
    appUserCubit = MockAppUserCubit();

    when(() => appUserCubit.stream)
        .thenAnswer((_) => const Stream<AppUserState>.empty());
    when(() => appLeagueCubit.updateLeagues(any())).thenAnswer((_) async {});
    when(() => appLeagueCubit.selectLeague(any())).thenAnswer((_) async {});
  });

  LeagueBloc buildBloc() {
    return LeagueBloc(
      createLeague: FakeCreateLeague(),
      deleteLeague: FakeDeleteLeague(),
      getLeague: getLeague,
      joinLeague: FakeJoinLeague(),
      exitLeague: FakeExitLeague(),
      updateLeagueInfo: FakeUpdateLeagueInfo(),
      updateTeamName: FakeUpdateTeamName(),
      addAdministrators: FakeAddAdministrators(),
      removeParticipants: FakeRemoveParticipants(),
      addEvent: FakeAddEvent(),
      removeEvent: FakeRemoveEvent(),
      addMemory: FakeAddMemory(),
      removeMemory: FakeRemoveMemory(),
      updateRule: FakeUpdateRule(),
      deleteRule: FakeDeleteRule(),
      addRule: FakeAddRule(),
      searchLeague: FakeSearchLeague(),
      getNotes: FakeGetNotes(),
      saveNote: FakeSaveNote(),
      deleteNote: FakeDeleteNote(),
      uploadMedia: FakeUploadMedia(),
      uploadTeamLogo: FakeUploadTeamLogo(),
      updateTeamLogo: FakeUpdateTeamLogo(),
      appUserCubit: appUserCubit,
      appLeagueCubit: appLeagueCubit,
    );
  }

  group('LeagueBloc', () {
    blocTest<LeagueBloc, LeagueState>(
      'GetLeagueEvent aggiorna la lega anche nella lista globale',
      build: () {
        when(() => getLeague(any()))
            .thenAnswer((_) async => right(tPartnerLeagueModel));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GetLeagueEvent(leagueId: 'league-1')),
      expect: () => [
        const LeagueLoading(),
        LeagueSuccess(
          league: tPartnerLeagueModel,
          operation: 'get_league',
        ),
      ],
      verify: (_) {
        verify(() => appLeagueCubit.updateLeagues(tPartnerLeagueModel))
            .called(1);
        verifyNever(() => appLeagueCubit.selectLeague(any()));
      },
    );
  });
}
