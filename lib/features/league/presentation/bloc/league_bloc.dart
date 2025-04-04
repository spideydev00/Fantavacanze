import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_event.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/create_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/exit_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/join_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_team_name.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeagueBloc extends Bloc<LeagueEvent, LeagueState> {
  final CreateLeague createLeague;
  final GetLeague getLeague;
  final JoinLeague joinLeague;
  final ExitLeague exitLeague;
  final UpdateTeamName updateTeamName;
  final AddEvent addEvent;
  final AddMemory addMemory;
  final SupabaseClient supabaseClient;

  LeagueBloc({
    required this.createLeague,
    required this.getLeague,
    required this.joinLeague,
    required this.exitLeague,
    required this.updateTeamName,
    required this.addEvent,
    required this.addMemory,
    required this.supabaseClient,
  }) : super(LeagueInitial()) {
    on<CreateLeagueEvent>(_onCreateLeague);
    on<GetLeagueEvent>(_onGetLeague);
    on<JoinLeagueEvent>(_onJoinLeague);
    on<ExitLeagueEvent>(_onExitLeague);
    on<UpdateTeamNameEvent>(_onUpdateTeamName);
    on<AddEventEvent>(_onAddEvent);
    on<AddMemoryEvent>(_onAddMemory);
  }

  Future<void> _onCreateLeague(
    CreateLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const LeagueError(message: 'User not authenticated'));
        return;
      }

      // Create rules from provided data
      final rules = event.rules.map((rule) {
        final type = rule['type'] == 'bonus' ? RuleType.bonus : RuleType.malus;
        return {
          'name': rule['name'],
          'type': rule['type'],
          'points': rule['points'],
        };
      }).toList();

      // Create league
      final result = await createLeague(
        CreateLeagueParams(
          name: event.name,
          description: event.description,
          isTeamBased: event.isTeamBased,
          admins: [currentUser.id],
          rules: rules,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) => emit(LeagueCreated(league: league)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

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
        (league) => emit(LeagueLoaded(league: league)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  Future<void> _onJoinLeague(
    JoinLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const LeagueError(message: 'User not authenticated'));
        return;
      }

      final result = await joinLeague(
        JoinLeagueParams(
          inviteCode: event.inviteCode,
          userId: currentUser.id,
          teamName: event.teamName,
          teamMembers: event.teamMembers,
          specificLeagueId: event.specificLeagueId,
        ),
      );

      result.fold(
        (failure) {
          // Check if we have multiple leagues with same invite code
          if (failure.data != null && failure.data is List) {
            emit(MultiplePossibleLeagues(
              inviteCode: event.inviteCode,
              possibleLeagues: failure.data,
            ));
          } else {
            emit(LeagueError(message: failure.message));
          }
        },
        (league) => emit(LeagueJoined(league: league)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  Future<void> _onExitLeague(
    ExitLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const LeagueError(message: 'User not authenticated'));
        return;
      }

      final result = await exitLeague(
        ExitLeagueParams(
          leagueId: event.leagueId,
          userId: currentUser.id,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) => emit(LeagueExited(league: league)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTeamName(
    UpdateTeamNameEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const LeagueError(message: 'User not authenticated'));
        return;
      }

      final result = await updateTeamName(
        UpdateTeamNameParams(
          leagueId: event.leagueId,
          userId: currentUser.id,
          newName: event.newName,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) => emit(TeamNameUpdated(league: league)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  Future<void> _onAddEvent(
    AddEventEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const LeagueError(message: 'User not authenticated'));
        return;
      }

      final result = await addEvent(AddEventParams(
        leagueId: event.leagueId,
        name: event.name,
        points: event.points,
        userId: currentUser.id,
        description: event.description,
      ));

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) => emit(EventAdded(league: league)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  Future<void> _onAddMemory(
    AddMemoryEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const LeagueError(message: 'User not authenticated'));
        return;
      }

      final result = await addMemory(AddMemoryParams(
        leagueId: event.leagueId,
        imageUrl: event.imageUrl,
        text: event.text,
        userId: currentUser.id,
        relatedEventId: event.relatedEventId,
      ));

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) => emit(MemoryAdded(league: league)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }
}
