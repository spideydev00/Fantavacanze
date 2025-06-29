import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/notification.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/approve_daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/reject_daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/unlock_daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/events/add_event.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/memory/add_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/delete_notification.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/get_notifications.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/mark_notification_as_read.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/rules/add_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/create_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notes/delete_note.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/rules/delete_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/exit_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/get_daily_challenges.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/get_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notes/get_notes.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/join_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notifications/listen_to_notification.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/mark_challenge_as_completed.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/memory/remove_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/remove_team_participants.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/notes/save_note.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/search_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/update_challenge_refresh_status.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/rules/update_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/update_team_name.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/upload_image.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/upload_team_logo.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/update_team_logo.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/add_administrators.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/remove_participants.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/update_league_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/delete_league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_state.dart';

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

  //cubits
  final AppUserCubit appUserCubit;
  final AppLeagueCubit appLeagueCubit;
  final NotificationCountCubit notificationCountCubit;

  // Daily challenges and notifications
  final GetDailyChallenges getDailyChallenges;
  final UnlockDailyChallenge unlockDailyChallenge;
  final MarkChallengeAsCompleted markChallengeAsCompleted;
  final UpdateChallengeRefreshStatus updateChallengeRefreshStatus;
  final ListenToNotification listenToNotification;

  // Add missing notification use case properties
  final GetNotifications getNotifications;
  final MarkNotificationAsRead markNotificationAsRead;
  final DeleteNotification deleteNotification;
  final ApproveDailyChallenge approveDailyChallenge;
  final RejectDailyChallenge rejectDailyChallenge;

  // Stream subscription for notifications
  StreamSubscription<Notification>? _notificationSubscription;
  StreamSubscription? _appUserSubscription;

  LeagueBloc({
    required this.createLeague,
    required this.deleteLeague,
    required this.getLeague,
    required this.joinLeague,
    required this.exitLeague,
    required this.updateLeagueInfo,
    required this.updateTeamName,
    required this.addAdministrators,
    required this.removeTeamParticipants,
    required this.removeParticipants,
    required this.addEvent,
    required this.addMemory,
    required this.removeMemory,
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
    //cubits
    required this.appUserCubit,
    required this.appLeagueCubit,
    required this.notificationCountCubit,
    //challenges
    required this.getDailyChallenges,
    required this.unlockDailyChallenge,
    required this.markChallengeAsCompleted,
    required this.updateChallengeRefreshStatus,
    required this.approveDailyChallenge,
    required this.rejectDailyChallenge,
    //notifications
    required this.listenToNotification,
    required this.getNotifications,
    required this.markNotificationAsRead,
    required this.deleteNotification,
  }) : super(LeagueInitial()) {
    _appUserSubscription = appUserCubit.stream.listen((userState) {
      if (userState is AppUserInitial) {
        add(const LeagueResetStateEvent());
      }
    });

    // =====================================================================
    // EVENT REGISTRATION
    // =====================================================================
    on<CreateLeagueEvent>(_onCreateLeague);
    on<GetLeagueEvent>(_onGetLeague);
    on<SearchLeagueEvent>(_handleSearchLeague);
    on<JoinLeagueEvent>(_handleJoinLeague);
    on<ExitLeagueEvent>(_onExitLeague);
    on<UpdateTeamNameEvent>(_onUpdateTeamName);
    on<AddEventEvent>(_onAddEventEvent);
    on<AddMemoryEvent>(_onAddMemory);
    on<RemoveMemoryEvent>(_onRemoveMemory);
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
    on<ListenToNotificationEvent>(_onListenToNotification);
    on<GetNotificationsEvent>(_onGetNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<LeagueResetStateEvent>((event, emit) {
      emit(LeagueInitial());
    });
  }

  // =====================================================================
  // LEAGUE MAIN OPERATIONS
  // =====================================================================

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
      (league) async {
        emit(LeagueSuccess(league: league, operation: 'create_league'));

        // Delete previous selected league from shared preferences
        appLeagueCubit.selectLeague(league);

        // Make sure to update the list of user leagues
        await appLeagueCubit.getUserLeagues();
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
        (league) async {
          emit(LeagueSuccess(
            league: league,
            operation: 'join_league',
          ));

          // Delete previous selected league from shared preferences
          appLeagueCubit.selectLeague(league);

          // Make sure to update the list of user leagues
          await appLeagueCubit.getUserLeagues();
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
        (_) async {
          emit(ExitLeagueSuccess());
          // Remove selected league from shared preferences
          appLeagueCubit.clearSelectedLeague();

          // Refresh app league cubit after exiting
          await appLeagueCubit.getUserLeagues();
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
        (league) {
          appLeagueCubit.selectLeague(league);

          emit(LeagueSuccess(league: league, operation: 'get_league'));
        },
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
      (_) async {
        emit(DeleteLeagueSuccess());

        // Remove selected league from shared preferences
        appLeagueCubit.clearSelectedLeague();

        // Refresh app league cubit after exiting
        await appLeagueCubit.getUserLeagues();
      },
    );
  }

  // =====================================================================
  // RULES MANAGEMENT
  // =====================================================================

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

  // =====================================================================
  // MEMBERSHIP OPERATIONS
  // =====================================================================

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

  // =====================================================================
  // CONTENT MANAGEMENT
  // =====================================================================

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

  // =====================================================================
  // NOTES MANAGEMENT
  // =====================================================================

  // G E T   N O T E S
  Future<void> _onGetNotes(
    GetNotesEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(const LeagueLoading());

    final result = await getNotes(event.leagueId);

    result.fold((failure) {
      emit(LeagueError(message: failure.message));
    }, (notes) {
      emit(NoteSuccess(
        operation: 'get',
        leagueId: event.leagueId,
        notes: notes,
      ));
    });
  }

  // S A V E   N O T E
  Future<void> _onSaveNote(
    SaveNoteEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(const LeagueLoading());

    // Make sure the note's leagueId matches the event leagueId
    final noteWithLeagueId = event.note;

    final result = await saveNote(SaveNoteParams(
      leagueId: event.leagueId,
      note: noteWithLeagueId,
    ));

    await result.fold(
      (failure) async {
        emit(LeagueError(message: failure.message));
      },
      (_) async {
        // After successful save, fetch all notes for that league
        final getNotesResult = await getNotes(event.leagueId);
        getNotesResult.fold((failure) {
          final errorMessage =
              "Failed to reload notes after saving: ${failure.message}";
          emit(LeagueError(message: errorMessage));
        }, (updatedNotes) {
          emit(NoteSuccess(
            operation: 'save',
            leagueId: event.leagueId,
            notes: updatedNotes,
          ));
        });
      },
    );
  }

  // D E L E T E   N O T E
  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(const LeagueLoading());

    final result = await deleteNote(DeleteNoteParams(
      leagueId: event.leagueId,
      noteId: event.noteId,
    ));

    await result.fold(
      (failure) async {
        emit(LeagueError(message: failure.message));
      },
      (_) async {
        // After successful delete, fetch all notes for that league
        final getNotesResult = await getNotes(event.leagueId);
        getNotesResult.fold((failure) {
          final errorMessage =
              "Failed to reload notes after deleting: ${failure.message}";
          emit(LeagueError(message: errorMessage));
        }, (updatedNotes) {
          emit(NoteSuccess(
            operation: 'delete', // Keep operation as 'delete'
            leagueId: event.leagueId,
            notes: updatedNotes, // Include the updated notes
          ));
        });
      },
    );
  }

  // =====================================================================
  // IMAGE UPLOAD
  // =====================================================================

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

  // =====================================================================
  // TEAM LOGO MANAGEMENT
  // =====================================================================

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
        teamName: event.teamName,
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

  // =====================================================================
  // ADMIN OPERATIONS
  // =====================================================================

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
  // =====================================================================
  // NOTIFICATIONS OPERATIONS
  // =====================================================================

  Future<void> _onListenToNotification(
    ListenToNotificationEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    _notificationSubscription?.cancel();

    final result = await listenToNotification.call(NoParams());

    result.fold(
      (failure) {
        emit(LeagueError(message: failure.message));
      },
      (notificationStream) {
        emit.forEach<Notification>(
          notificationStream,
          onData: (notification) {
            // Increment notification count
            notificationCountCubit.increment();
            // Return the notification state that will be emitted
            return NotificationReceived(notification: notification);
          },
          onError: (error, stackTrace) =>
              LeagueError(message: error.toString()),
        );
      },
    );
  }

  // M E T O D O   P E R   L A   C H I U S U R A
  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    _appUserSubscription?.cancel();

    return super.close();
  }

  // Fix the _onGetNotifications method to properly count unread notifications
  Future<void> _onGetNotifications(
    GetNotificationsEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await getNotifications(NoParams());

    result.fold((failure) => emit(LeagueError(message: failure.message)),
        (notifications) {
      // Update notification count in the cubit - count ALL unread notifications
      final unreadCount = notifications.where((n) => !n.isRead).length;
      notificationCountCubit.setCount(unreadCount);

      emit(NotificationsLoaded(notifications: notifications));
    });
  }

  // Fix notification marking as read - only decrement count for non-daily challenge notifications
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result =
        await markNotificationAsRead.call(MarkNotificationAsReadParams(
      notificationId: event.notificationId,
    ));

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (_) {
        // Update notification count only if this is a regular notification
        // For daily challenges, we'll handle this when they're approved/rejected
        emit(NotificationActionSuccess(
          action: 'mark_as_read',
          notificationId: event.notificationId,
        ));
      },
    );
  }

  // Method to handle notification deletion
  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await deleteNotification.call(
      DeleteNotificationParams(notificationId: event.notificationId),
    );

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (_) {
        // Decrement notification count since we're removing a notification
        notificationCountCubit.decrement();

        // Emit success with the notification ID to remove it from the UI
        emit(NotificationActionSuccess(
          action: 'delete',
          notificationId: event.notificationId,
        ));
      },
    );
  }

  // =====================================================================
  // UTILITY METHODS
  // =====================================================================

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
