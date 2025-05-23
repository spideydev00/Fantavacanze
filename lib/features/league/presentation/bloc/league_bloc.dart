import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_event.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/create_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/delete_note.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/delete_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/exit_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_notes.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_rules.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/join_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remove_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remove_team_participants.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/save_note.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/search_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_team_name.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/upload_image.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/upload_team_logo.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_team_logo.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_administrators.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remove_participants.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_league_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/delete_league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';

class LeagueBloc extends Bloc<LeagueEvent, LeagueState> {
  final CreateLeague createLeague;
  final GetLeague getLeague;
  final JoinLeague joinLeague;
  final ExitLeague exitLeague;
  final UpdateTeamName updateTeamName;
  final AddEvent addEvent;
  final AddMemory addMemory;
  final RemoveMemory removeMemory;
  final RemoveTeamParticipants removeTeamParticipants;
  final GetRules getRules;
  final UpdateRule updateRule;
  final DeleteRule deleteRule;
  final AddRule addRule;
  final SearchLeague searchLeague;
  final GetNotes getNotes;
  final SaveNote saveNote;
  final DeleteNote deleteNote;
  final UploadImage uploadImage;
  final UploadTeamLogo uploadTeamLogo;
  final UpdateTeamLogo updateTeamLogo;
  final AddAdministrators addAdministrators;
  final RemoveParticipants removeParticipants;
  final UpdateLeagueInfo updateLeagueInfo;
  final DeleteLeague deleteLeague;
  final AppUserCubit appUserCubit;
  final AppLeagueCubit appLeagueCubit;

  LeagueBloc({
    required this.createLeague,
    required this.getLeague,
    required this.joinLeague,
    required this.exitLeague,
    required this.updateTeamName,
    required this.addEvent,
    required this.addMemory,
    required this.removeMemory,
    required this.getRules,
    required this.updateRule,
    required this.deleteRule,
    required this.addRule,
    required this.searchLeague,
    required this.getNotes,
    required this.saveNote,
    required this.deleteNote,
    required this.uploadImage,
    required this.uploadTeamLogo,
    required this.updateTeamLogo,
    required this.appUserCubit,
    required this.appLeagueCubit,
    required this.removeTeamParticipants,
    required this.addAdministrators,
    required this.removeParticipants,
    required this.updateLeagueInfo,
    required this.deleteLeague,
  }) : super(LeagueInitial()) {
    on<CreateLeagueEvent>(_onCreateLeague);
    on<GetLeagueEvent>(_onGetLeague);
    on<SearchLeagueEvent>(_handleSearchLeague);
    on<JoinLeagueEvent>(_handleJoinLeague);
    on<ExitLeagueEvent>(_onExitLeague);
    on<UpdateTeamNameEvent>(_onUpdateTeamName);
    on<AddEventEvent>(_onAddEventEvent);
    on<AddMemoryEvent>(_onAddMemory);
    on<RemoveMemoryEvent>(_onRemoveMemory);
    on<GetRulesEvent>(_onGetRules);
    on<UpdateRuleEvent>(_onUpdateRule);
    on<DeleteRuleEvent>(_onDeleteRule);
    on<AddRuleEvent>(_onAddRule);
    on<RemoveTeamParticipantsEvent>(_handleRemoveTeamParticipants);
    on<GetNotesEvent>(_onGetNotes);
    on<SaveNoteEvent>(_onSaveNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<UploadImageEvent>(_onUploadImage);
    on<UploadTeamLogoEvent>(_onUploadTeamLogo);
    on<UpdateTeamLogoEvent>(_onUpdateTeamLogo);
    on<AddAdministratorsEvent>(_onAddAdministrators);
    on<RemoveParticipantsEvent>(_onRemoveParticipants);
    on<UpdateLeagueInfoEvent>(_onUpdateLeagueInfo);
    on<DeleteLeagueEvent>(_onDeleteLeague);
  }

  // -----------------------------------------------------------
  // L E A G U E   M A I N   O P E R A T I O N S
  // -----------------------------------------------------------

  // C R E A T E   L E A G U E
  Future<void> _onCreateLeague(
    CreateLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await createLeague(
      CreateLeagueParams(
        name: event.name,
        description: event.description ?? "",
        isTeamBased: event.isTeamBased,
        rules: event.rules,
      ),
    );

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (league) {
        emit(LeagueSuccess(league: league, operation: 'create_league'));

        // Delete previous selected league from shared preferences
        appLeagueCubit.selectLeague(league);

        // Make sure to update the list of user leagues
        appLeagueCubit.getUserLeagues();
      },
    );
  }

  // S E A R C H   L E A G U E
  Future<void> _handleSearchLeague(
    SearchLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());
    final result = await searchLeague(
      SearchLeagueParams(inviteCode: event.inviteCode),
    );
    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (leagues) {
        if (leagues.isEmpty) {
          emit(const LeagueError(
              message: "Nessuna lega trovata con questo codice"));
        } else if (leagues.length == 1) {
          emit(LeagueWithInviteCode(
            league: leagues.first,
            inviteCode: event.inviteCode,
          ));
        } else {
          emit(MultiplePossibleLeagues(
            possibleLeagues: leagues,
            inviteCode: event.inviteCode,
          ));
        }
      },
    );
  }

  // J O I N   L E A G U E
  void _handleJoinLeague(
    JoinLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    try {
      final result = await joinLeague(
        JoinLeagueParams(
          inviteCode: event.inviteCode,
          teamName: event.teamName,
          teamMembers: event.teamMembers,
          specificLeagueId: event.specificLeagueId,
        ),
      );

      result.fold(
        (failure) {
          emit(LeagueError(message: failure.message));
        },
        (league) {
          emit(LeagueSuccess(
            league: league,
            operation: 'join_league',
          ));

          // Delete previous selected league from shared preferences
          appLeagueCubit.selectLeague(league);

          // Make sure to update the list of user leagues
          appLeagueCubit.getUserLeagues();
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // E X I T   L E A G U E
  Future<void> _onExitLeague(
    ExitLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      late String userId;
      final state = appUserCubit.state;

      if (state is AppUserIsLoggedIn) {
        userId = state.user.id;
      }

      final result = await exitLeague(
        ExitLeagueParams(
          league: event.league,
          userId: userId,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (_) {
          emit(ExitLeagueSuccess());
          // Remove selected league from shared preferences
          appLeagueCubit.clearSelectedLeague();

          // Refresh app league cubit after exiting
          appLeagueCubit.getUserLeagues();
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // G E T   L E A G U E
  Future<void> _onGetLeague(
    GetLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final result = await getLeague(
        GetLeagueParams(
          leagueId: event.leagueId,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) =>
            emit(LeagueSuccess(league: league, operation: 'get_league')),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // D E L E T E   L E A G U E
  Future<void> _onDeleteLeague(
    DeleteLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result =
        await deleteLeague(DeleteLeagueParams(leagueId: event.leagueId));

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (_) {
        emit(DeleteLeagueSuccess());

        // Remove selected league from shared preferences
        appLeagueCubit.clearSelectedLeague();

        // Refresh app league cubit after exiting
        appLeagueCubit.getUserLeagues();
      },
    );
  }

  // -----------------------------------------------------------
  // R U L E S   M A N A G E M E N T
  // -----------------------------------------------------------

  // G E T   R U L E S
  Future<void> _onGetRules(
    GetRulesEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      // Validate mode parameter
      if (event.mode != "hard" && event.mode != "soft") {
        emit(const LeagueError(message: "Invalid mode. Use 'hard' or 'soft'"));
        return;
      }

      final result = await getRules(event.mode);

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (rules) => emit(RulesLoaded(rules: rules, mode: event.mode)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // U P D A T E   R U L E
  Future<void> _onUpdateRule(
      UpdateRuleEvent event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    final result = await updateRule(
      UpdateRuleParams(
        league: event.league,
        rule: event.rule,
        originalRuleName: event.originalRuleName,
      ),
    );

    result.fold(
      (failure) => LeagueError(message: failure.message),
      (league) {
        emit(LeagueSuccess(league: league, operation: 'update_rule'));

        appLeagueCubit.selectLeague(league);
      },
    );
  }

  // D E L E T E   R U L E
  Future<void> _onDeleteRule(
      DeleteRuleEvent event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    final result = await deleteRule(
      DeleteRuleParams(
        league: event.league,
        ruleName: event.ruleName,
      ),
    );

    result.fold(
      (failure) => LeagueError(message: failure.message),
      (league) {
        emit(LeagueSuccess(league: league, operation: 'delete_rule'));

        appLeagueCubit.selectLeague(league);
      },
    );
  }

  // A D D   R U L E
  Future<void> _onAddRule(AddRuleEvent event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    final result = await addRule(
      AddRuleParams(
        league: event.league,
        rule: event.rule,
      ),
    );

    result.fold(
      (failure) => LeagueError(message: failure.message),
      (league) {
        emit(LeagueSuccess(league: league, operation: 'add_rule'));

        appLeagueCubit.selectLeague(league);
      },
    );
  }

  // -----------------------------------------------------------
  // M E M B E R S H I P   O P E R A T I O N S
  // -----------------------------------------------------------

  // U P D A T E   T E A M   N A M E
  Future<void> _onUpdateTeamName(
    UpdateTeamNameEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      late String userId;
      final state = appUserCubit.state;

      if (state is AppUserIsLoggedIn) {
        userId = state.user.id;
      }

      final result = await updateTeamName(
        UpdateTeamNameParams(
          league: event.league,
          userId: userId,
          newName: event.newName,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(LeagueSuccess(league: league, operation: 'update_team_name'));

          appLeagueCubit.selectLeague(league);
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // -----------------------------------------------------------
  // C O N T E N T   M A N A G E M E N T
  // -----------------------------------------------------------

  // A D D   E V E N T
  Future<void> _onAddEventEvent(
    AddEventEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());
    final result = await addEvent(
      AddEventParams(
        league: event.league,
        name: event.name,
        points: event.points,
        creatorId: event.creatorId,
        targetUser: event.targetUser,
        type: event.type,
        description: event.description,
        isTeamMember: event.isTeamMember,
      ),
    );

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (league) {
        emit(LeagueSuccess(league: league, operation: 'add_event'));

        appLeagueCubit.selectLeague(league);
      },
    );
  }

  // A D D   M E M O R Y
  Future<void> _onAddMemory(
    AddMemoryEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final result = await addMemory(AddMemoryParams(
        league: event.league,
        imageUrl: event.imageUrl,
        text: event.text,
        userId: event.userId,
        relatedEventId: event.relatedEventId,
        eventName: event.eventName,
      ));

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(LeagueSuccess(league: league, operation: 'add_memory'));

          appLeagueCubit.selectLeague(league);
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // R E M O V E   M E M O R Y
  Future<void> _onRemoveMemory(
    RemoveMemoryEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final result = await removeMemory(
        RemoveMemoryParams(
          league: event.league,
          memoryId: event.memoryId,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(LeagueSuccess(league: league, operation: 'remove_memory'));

          appLeagueCubit.selectLeague(league);
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // R E M O V E   T E A M   P A R T I C I P A N T S
  Future<void> _handleRemoveTeamParticipants(
    RemoveTeamParticipantsEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      // Ottieni l'ID dell'utente corrente
      late String requestingUserId;
      final userState = appUserCubit.state;

      if (userState is AppUserIsLoggedIn) {
        requestingUserId = userState.user.id;
      }

      final result = await removeTeamParticipants(
        RemoveTeamParticipantsParams(
          league: event.league,
          teamName: event.teamName,
          userIdsToRemove: event.userIdsToRemove,
          requestingUserId: requestingUserId,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(TeammatesRemovedState(league: league));

          appLeagueCubit.selectLeague(league);
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // -----------------------------------------------------------
  // N O T E S   M A N A G E M E N T
  // -----------------------------------------------------------

  // G E T   N O T E S
  Future<void> _onGetNotes(
    GetNotesEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await getNotes(event.leagueId);

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (notes) => emit(NoteSuccess(
        operation: 'get',
        leagueId: event.leagueId,
        notes: notes,
      )),
    );
  }

  // S A V E   N O T E
  Future<void> _onSaveNote(
    SaveNoteEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    // Make sure the note's leagueId matches the event leagueId
    final noteWithLeagueId = event.note;

    final result = await saveNote(SaveNoteParams(
      leagueId: event.leagueId,
      note: noteWithLeagueId,
    ));

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (_) => emit(NoteSuccess(
        operation: 'save',
        leagueId: event.leagueId,
      )),
    );
  }

  // D E L E T E   N O T E
  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await deleteNote(DeleteNoteParams(
      leagueId: event.leagueId,
      noteId: event.noteId,
    ));

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (_) => emit(NoteSuccess(
        operation: 'delete',
        leagueId: event.leagueId,
      )),
    );
  }

  // -----------------------------------------------------------
  // I M A G E   U P L O A D
  // -----------------------------------------------------------

  // Handle image upload
  Future<void> _onUploadImage(
    UploadImageEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await uploadImage(
      UploadImageParams(
        leagueId: event.leagueId,
        imageFile: event.imageFile,
      ),
    );

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (imageUrl) => emit(ImageUploadSuccess(imageUrl: imageUrl)),
    );
  }

  // -----------------------------------------------------------
  // T E A M   L O G O   M A N A G E M E N T
  // -----------------------------------------------------------

  // Handle team logo upload
  Future<void> _onUploadTeamLogo(
    UploadTeamLogoEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await uploadTeamLogo(
      UploadTeamLogoParams(
        leagueId: event.leagueId,
        teamName: event.teamName,
        imageFile: event.imageFile,
      ),
    );

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (logoUrl) => emit(TeamLogoUploadSuccess(
        logoUrl: logoUrl,
        teamName: event.teamName, // Changed from teamId to teamName
      )),
    );
  }

  // Handle team logo update in league
  Future<void> _onUpdateTeamLogo(
    UpdateTeamLogoEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await updateTeamLogo(
      UpdateTeamLogoParams(
        league: event.league,
        teamName: event.teamName,
        logoUrl: event.logoUrl,
      ),
    );

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (league) {
        emit(LeagueSuccess(league: league, operation: 'update_team_logo'));
        appLeagueCubit.selectLeague(league);
      },
    );
  }

  // -----------------------------------------------------------
  // A D M I N   O P E R A T I O N S
  // -----------------------------------------------------------

  // Add Administrators
  Future<void> _onAddAdministrators(
    AddAdministratorsEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await addAdministrators(
      AddAdministratorsParams(
        league: event.league,
        userIds: event.userIds,
      ),
    );

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (league) {
        emit(AdminOperationSuccess(
          league: league,
          operation: 'add_administrators',
        ));

        appLeagueCubit.selectLeague(league);
      },
    );
  }

  // Remove Participants
  Future<void> _onRemoveParticipants(
    RemoveParticipantsEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await removeParticipants(
      RemoveParticipantsParams(
        league: event.league,
        participantIds: event.participantIds,
        newCaptainId: event.newCaptainId,
      ),
    );

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (league) {
        emit(AdminOperationSuccess(
          league: league,
          operation: 'remove_participants',
        ));

        // Update the current selected league
        appLeagueCubit.selectLeague(league);
      },
    );
  }

  // Update League Info
  Future<void> _onUpdateLeagueInfo(
    UpdateLeagueInfoEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await updateLeagueInfo(
      UpdateLeagueInfoParams(
        league: event.league,
        name: event.name,
        description: event.description,
      ),
    );

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (league) {
        emit(AdminOperationSuccess(
          league: league,
          operation: 'update_league_info',
        ));

        final updatedLeague = league;

        // Use the existing selectLeague method to ensure persistence is maintained
        appLeagueCubit.updateLeagues(updatedLeague);
      },
    );
  }

  // -----------------------------------------------------------
  // U T I L I T Y   M E T H O D S
  // -----------------------------------------------------------

  // Helper method to check if current user is admin of the selected league
  bool isAdmin() {
    // Get current user ID
    final userState = appUserCubit.state;
    if (userState is! AppUserIsLoggedIn) {
      return false;
    }

    final String userId = userState.user.id;

    // Check if there is a selected league in the app-wide cubit
    final leagueState = appLeagueCubit.state;
    if (leagueState is AppLeagueExists) {
      return leagueState.selectedLeague.admins.contains(userId);
    }

    return false;
  }
}
