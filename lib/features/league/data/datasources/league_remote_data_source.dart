import 'dart:io';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/event_model.dart';
import 'package:fantavacanze_official/features/league/data/models/individual_participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/memory_model.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model.dart';
import 'package:fantavacanze_official/features/league/data/models/team_participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/simple_participant_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class LeagueRemoteDataSource {
  Future<LeagueModel> createLeague({
    required String name,
    required String? description,
    required bool isTeamBased,
    required List<RuleModel> rules,
  });

  Future<LeagueModel> getLeague(String leagueId);

  Future<List<LeagueModel>> getUserLeagues();

  Future<LeagueModel> updateLeagueNameOrDescription({
    required String leagueId,
    String? name,
    String? description,
  });

  Future<void> deleteLeague(String leagueId);

  Future<List<LeagueModel>> searchLeague({required String inviteCode});

  Future<LeagueModel> joinLeague({
    required String inviteCode,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  });

  Future<void> exitLeague({
    required LeagueModel league,
    required String userId,
  });

  Future<LeagueModel> removeTeamParticipants({
    required LeagueModel league,
    required String teamName,
    required List<String> userIdsToRemove,
    required String requestingUserId,
  });

  Future<LeagueModel> updateTeamName({
    required LeagueModel league,
    required String userId,
    required String newName,
  });

  Future<LeagueModel> addEvent({
    required LeagueModel league,
    required String name,
    required int points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? description,
  });

  Future<LeagueModel> removeEvent({
    required LeagueModel league,
    required String eventId,
  });

  Future<LeagueModel> addMemory({
    required LeagueModel league,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
    String? eventName,
  });

  Future<LeagueModel> removeMemory({
    required LeagueModel league,
    required String memoryId,
  });

  Future<List<RuleModel>> getRules({required String mode});

  Future<LeagueModel> updateRule({
    required LeagueModel league,
    required RuleModel rule,
    String? originalRuleName,
  });

  Future<LeagueModel> deleteRule({
    required LeagueModel league,
    required String ruleName,
  });

  Future<LeagueModel> addRule({
    required LeagueModel league,
    required RuleModel rule,
  });

  Future<String> uploadImage({
    required String leagueId,
    required File imageFile,
  });

  Future<String> uploadTeamLogo({
    required String leagueId,
    required String teamName,
    required File imageFile,
  });

  Future<LeagueModel> updateTeamLogo({
    required LeagueModel league,
    required String teamName,
    required String logoUrl,
  });

  Future<LeagueModel> addAdministrators({
    required LeagueModel league,
    required List<String> userIds,
  });

  Future<LeagueModel> removeParticipants({
    required LeagueModel league,
    required List<String> participantIds,
    String? newCaptainId,
  });

  Future<LeagueModel> updateLeagueInfo({
    required LeagueModel league,
    String? name,
    String? description,
  });
}

class LeagueRemoteDataSourceImpl implements LeagueRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;
  final AppUserCubit appUserCubit;

  LeagueRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.uuid,
    required this.appUserCubit,
  });

  // ------------------------------------------------
  // C R E A T E   L E A G U E
  @override
  Future<LeagueModel> createLeague({
    required String name,
    required String? description,
    required bool isTeamBased,
    required List<RuleModel> rules,
  }) async {
    try {
      final String leagueId = uuid.v4();
      final String inviteCode = uuid.v4().substring(0, 10);

      // Get creator info
      final creatorId = _checkAuthentication();
      final creatorName = _getCurrentUserName();

      // Create initial participant
      final initialParticipant = _createInitialParticipant(
        isTeamBased: isTeamBased,
        creatorId: creatorId,
        creatorName: creatorName!,
      );

      final leagueData = {
        'id': leagueId,
        'invite_code': inviteCode,
        'admins': [creatorId],
        'name': name,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
        'rules': rules.map((rule) => rule.toJson()).toList(),
        'participants': [initialParticipant.toJson()],
        'events': [],
        'memories': [],
        'is_team_based': isTeamBased,
      };

      final response = await supabaseClient
          .from('leagues')
          .insert(leagueData)
          .select()
          .single();

      return _convertResponseToModel(response);
    } catch (e) {
      throw ServerException(
          'Si è verificato un errore durante la creazione: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // G E T   L E A G U E
  @override
  Future<LeagueModel> getLeague(String leagueId) async {
    return await _getLeagueData(leagueId);
  }

  // ------------------------------------------------
  // G E T   U S E R   L E A G U E S
  @override
  Future<List<LeagueModel>> getUserLeagues() async {
    try {
      final currentUserId = _checkAuthentication();

      // Use the RPC function to get all leagues where user is admin or participant
      List<Map<String, dynamic>> leaguesResponse = await supabaseClient.rpc(
        'get_user_leagues',
        params: {'p_user_id': currentUserId},
      );

      final List<LeagueModel> leagues = [];

      // Process response
      for (final league in leaguesResponse) {
        leagues.add(_convertResponseToModel(league));
      }
      return leagues;
    } catch (e) {
      throw ServerException(
          'Si è verificato un errore durante il caricamento delle leghe: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // U P D A T E   L E A G U E
  @override
  Future<LeagueModel> updateLeagueNameOrDescription({
    required String leagueId,
    String? name,
    String? description,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;

      if (updateData.isEmpty) {
        // Nothing to update, return current league
        return await _getLeagueData(leagueId);
      }

      return await _updateLeagueInDb(
        leagueId: leagueId,
        updateData: updateData,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // D E L E T E   L E A G U E
  @override
  Future<void> deleteLeague(String leagueId) async {
    try {
      await supabaseClient.from('leagues').delete().eq('id', leagueId);
    } catch (e) {
      throw ServerException(
          'Si è verificato un errore durante la cancellazione: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // S E A R C H   L E A G U E
  @override
  Future<List<LeagueModel>> searchLeague({required String inviteCode}) async {
    try {
      final response = await supabaseClient.rpc(
        'search_league_by_invite_code',
        params: {'p_invite_code': inviteCode},
      );
      final result = response as Map<String, dynamic>;
      final leaguesJson = result['leagues'] as List<dynamic>? ?? [];
      final leagues = leaguesJson
          .map((json) =>
              _convertResponseToModel(Map<String, dynamic>.from(json)))
          .toList();

      // Check if user is already a participant in any of the found leagues
      final currentUserId = _getCurrentUserId();
      if (currentUserId != null) {
        for (final league in leagues) {
          final isParticipant = league.participants.any((participant) {
            // Team-based: check userIds, Individual: check userId
            final json = (participant as ParticipantModel).toJson();
            if (league.isTeamBased) {
              final members = (json['members'] as List?)
                      ?.map((member) => SimpleParticipantModel.fromJson(member))
                      .toList() ??
                  [];
              return members.any((member) => member.userId == currentUserId);
            } else {
              return json['userId'] == currentUserId;
            }
          });
          if (isParticipant) {
            throw ServerException(
                "Sei già iscritto a questa lega: ${league.name}");
          }
        }
      }

      return leagues;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          'Si è verificato un errore durante la ricerca della lega: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // J O I N   L E A G U E
  @override
  Future<LeagueModel> joinLeague({
    required String inviteCode,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  }) async {
    try {
      final currentUserId = _checkAuthentication();
      final currentUserName = _getCurrentUserName() ?? "Utente";

      // Create a SimpleParticipantModel for the current user
      final currentUserParticipant = SimpleParticipantModel(
        userId: currentUserId,
        name: currentUserName,
      );

      // Call the RPC function
      final response = await supabaseClient.rpc(
        'join_league',
        params: {
          'p_user_id': currentUserId,
          'p_user_name': currentUserName,
          'p_invite_code': inviteCode,
          'p_team_name': teamName,
          'p_specific_league_id': specificLeagueId,
          'p_member_details': currentUserParticipant.toJson(),
        },
      );

      final result = response as Map<String, dynamic>;
      final status = result['status'] as String;

      if (status == 'joined') {
        final leagueData = result['league'] as Map<String, dynamic>;
        return _convertResponseToModel(leagueData);
      } else {
        throw ServerException('Risposta inattesa dal server');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // E X I T   L E A G U E
  @override
  Future<void> exitLeague({
    required LeagueModel league,
    required String userId,
  }) async {
    try {
      // Controlla se è una lega a squadre o individuale
      if (league.isTeamBased) {
        await _exitTeamLeague(league, userId);
      } else {
        await _exitIndividualLeague(league, userId);
      }
    } catch (e) {
      throw ServerException(
          'Si è verificato un errore nell\'uscire dalla lega: ${e.toString()}');
    }
  }

  // Gestisce l'uscita da una lega individuale
  Future<void> _exitIndividualLeague(
    LeagueModel league,
    String userId,
  ) async {
    // Trova l'utente nei partecipanti
    int participantIndex = -1;

    for (int i = 0; i < league.participants.length; i++) {
      final participant = league.participants[i];
      if (participant is IndividualParticipantModel &&
          participant.userId == userId) {
        participantIndex = i;
        break;
      }
    }

    if (participantIndex == -1) {
      throw ServerException('Utente non trovato nei partecipanti della lega');
    }

    // Se è l'unico partecipante, elimina la lega
    if (league.participants.length == 1) {
      await deleteLeague(league.id);
      return; // Early return if we delete the league
    }

    // Altrimenti rimuovi solo il partecipante
    final updatedParticipants = List<dynamic>.from(league.participants)
      ..removeAt(participantIndex);

    await _updateLeagueInDb(
      leagueId: league.id,
      updateData: {
        'participants': updatedParticipants
            .map((p) => (p as ParticipantModel).toJson())
            .toList(),
      },
    );
  }

  // Gestisce l'uscita da una lega a squadre
  Future<void> _exitTeamLeague(
    LeagueModel league,
    String userId,
  ) async {
    try {
      // Trova il team del partecipante
      int teamIndex = -1;
      TeamParticipantModel? team;

      for (int i = 0; i < league.participants.length; i++) {
        final participant = league.participants[i];
        if (participant is TeamParticipantModel &&
            participant.members.any((member) => member.userId == userId)) {
          teamIndex = i;
          team = participant;
          break;
        }
      }

      if (teamIndex == -1 || team == null) {
        throw ServerException('Utente non trovato in nessun team della lega');
      }

      // Se è l'ultimo membro del team, rimuovi il team
      if (team.members.length == 1) {
        // Se è anche l'ultimo team, elimina la lega
        if (league.participants.length == 1) {
          await deleteLeague(league.id);
          return; // Early return if we delete the league
        }

        // Altrimenti rimuovi solo il team
        final updatedParticipants = List<dynamic>.from(league.participants)
          ..removeAt(teamIndex);

        await _updateLeagueInDb(
          leagueId: league.id,
          updateData: {
            'participants': updatedParticipants
                .map((p) => (p as ParticipantModel).toJson())
                .toList(),
          },
        );
        return;
      }

      // Se ci sono altri membri nel team, rimuovi solo l'utente
      final updatedMembers =
          team.members.where((member) => member.userId != userId).toList();

      // Crea il team aggiornato
      final updatedTeam = TeamParticipantModel(
        members: updatedMembers,
        captainId: team.captainId,
        name: team.name,
        points: team.points,
        malusTotal: team.malusTotal,
        bonusTotal: team.bonusTotal,
        teamLogoUrl: team.teamLogoUrl,
      );

      // Aggiorna la lista dei partecipanti
      final updatedParticipants = List<dynamic>.from(league.participants);
      updatedParticipants[teamIndex] = updatedTeam;

      await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'participants': updatedParticipants
              .map((p) => (p as ParticipantModel).toJson())
              .toList(),
        },
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          "Si è verificato un errore durante l'uscita: ${e.toString()}");
    }
  }

  // ------------------------------------------------
  // U P D A T E   T E A M   N A M E
  @override
  Future<LeagueModel> updateTeamName({
    required LeagueModel league,
    required String userId,
    required String newName,
  }) async {
    try {
      if (!league.isTeamBased) {
        throw ServerException('Questa non è una lega basata su squadre');
      }

      // Find user's team
      final teamIndex = _findUserTeamIndex(league, userId);
      if (teamIndex == -1) {
        throw ServerException('L\'utente non fa parte di nessuna squadra');
      }

      // Update team name
      final updatedParticipants =
          _getUpdatedParticipantsWithNewTeamName(league, userId, newName);

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {'participants': updatedParticipants},
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // A D D   E V E N T
  @override
  Future<LeagueModel> addEvent({
    required LeagueModel league,
    required String name,
    required int points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? description,
  }) async {
    try {
      // Find the target participant
      ParticipantModel? targetParticipant =
          _findTargetParticipant(league: league, targetUser: targetUser);

      if (targetParticipant == null) {
        throw ServerException('Destinatario non trovato nella lega');
      }

      // Create event
      final eventData = _createEventData(
        name: name,
        points: points,
        creatorId: creatorId,
        targetUser: targetUser,
        type: type,
        description: description,
      );

      // Create updated events list
      final updatedEvents = _getUpdatedEventsList(league.events, eventData);

      // Update participant score and get updated participants list
      final updatedParticipants = _updateParticipantScore(
        league: league,
        targetParticipant: targetParticipant,
        targetUser: targetUser,
        points: points,
      );

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'events': updatedEvents.map((e) => e.toJson()).toList(),
          'participants': updatedParticipants,
        },
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException("Si è verificato un errore: ${e.toString()}");
    }
  }

  // ------------------------------------------------
  // R E M O V E   E V E N T
  @override
  Future<LeagueModel> removeEvent({
    required LeagueModel league,
    required String eventId,
  }) async {
    try {
      _checkAuthentication();

      // Find the event
      final eventIndex =
          league.events.indexWhere((e) => (e as EventModel).id == eventId);

      if (eventIndex == -1) {
        throw ServerException('Evento non trovato');
      }

      final EventModel eventToRemove = league.events[eventIndex] as EventModel;

      // Remove the event and update participant scores
      final updatedEvents = _getUpdatedEventsAfterRemoval(league, eventId);
      final updatedParticipants =
          _getUpdatedParticipantsAfterEventRemoval(league, eventToRemove);

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'events': updatedEvents,
          'participants': updatedParticipants,
        },
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // A D D   M E M O R Y
  @override
  Future<LeagueModel> addMemory({
    required LeagueModel league,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
    String? eventName,
  }) async {
    try {
      // Get the participant name based on userId
      final participantName = _getParticipantNameByUserId(league, userId);

      // Create new memory with participant name
      final memoryData = _createMemoryData(
        imageUrl: imageUrl,
        text: text,
        userId: userId,
        participantName: participantName,
        relatedEventId: relatedEventId,
        eventName: eventName,
      );

      // Add new memory to the list
      final updatedMemories = [
        ...league.memories.map((m) => m as MemoryModel),
        memoryData,
      ];

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'memories': updatedMemories.map((m) => m.toJson()).toList()
        },
      );
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // R E M O V E   M E M O R Y
  @override
  Future<LeagueModel> removeMemory({
    required LeagueModel league,
    required String memoryId,
  }) async {
    try {
      final currentUserId = _checkAuthentication();

      // Find the memory
      final memoryIndex =
          league.memories.indexWhere((m) => (m as MemoryModel).id == memoryId);

      if (memoryIndex == -1) {
        throw ServerException('Ricordo non trovato');
      }

      final memoryToRemove = league.memories[memoryIndex] as MemoryModel;

      // Check if user is the owner of the memory (admin check is done app-wide)
      if (memoryToRemove.userId != currentUserId) {
        throw ServerException(
            'Puoi rimuovere solo i tuoi ricordi a meno che tu non sia un amministratore');
      }

      // Delete the image from storage
      await _deleteFileFromStorage(
        bucket: 'memories',
        url: memoryToRemove.imageUrl,
      );

      // Remove the memory from the league
      final updatedMemories = _getUpdatedMemoriesAfterRemoval(league, memoryId);

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {'memories': updatedMemories},
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // G E T   R U L E S
  @override
  Future<List<RuleModel>> getRules({required String mode}) async {
    try {
      // Determine which table to query based on mode
      final tableName = mode == "hard" ? "hard_rules" : "soft_rules";

      // Execute the query
      final response = await supabaseClient.from(tableName).select();

      // Parse the response into a list of RuleModel objects
      return (response as List)
          .map((ruleJson) => RuleModel.fromJson(ruleJson))
          .toList();
    } catch (e) {
      throw ServerException(
          'Errore durante il fetching delle regole: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // U P D A T E   R U L E
  @override
  Future<LeagueModel> updateRule({
    required LeagueModel league,
    required RuleModel rule,
    String? originalRuleName,
  }) async {
    try {
      // originalRuleName is the name of the rule we want to replace
      final nameToFind = originalRuleName ?? rule.name;

      // Create updated rules list by replacing the rule with matching name
      final updatedRulesList = league.rules.map((currentRule) {
        if (currentRule.name == nameToFind) {
          return rule;
        }
        return currentRule;
      }).toList();

      // Format rules for database update
      final List<Map<String, dynamic>> rulesJson =
          updatedRulesList.map((rule) => (rule as RuleModel).toJson()).toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {'rules': rulesJson},
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // D E L E T E   R U L E
  @override
  Future<LeagueModel> deleteRule({
    required LeagueModel league,
    required String ruleName,
  }) async {
    try {
      // Filter out the rule to delete
      final remainingRules = league.rules
          .where((r) => (r.name != ruleName || !r.name.contains(ruleName)))
          .toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {'rules': remainingRules},
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // A D D   R U L E
  @override
  Future<LeagueModel> addRule({
    required LeagueModel league,
    required RuleModel rule,
  }) async {
    try {
      // Get all existing rules
      final List<RuleModel> existingRules =
          league.rules.map((r) => r as RuleModel).toList();

      // Insert the new rule
      final List<RuleModel> updatedRules = _insertRule(
        existingRules: existingRules,
        newRule: rule,
        ruleType: rule.type,
      );

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'rules': updatedRules.map((r) => r.toJson()).toList(),
        },
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // R E M O V E   T E A M   P A R T I C I P A N T S
  @override
  Future<LeagueModel> removeTeamParticipants({
    required LeagueModel league,
    required String teamName,
    required List<String> userIdsToRemove,
    required String requestingUserId,
  }) async {
    try {
      // Trova il team
      int teamIndex = -1;
      for (int i = 0; i < league.participants.length; i++) {
        final participant = league.participants[i] as ParticipantModel;
        final participantJson = participant.toJson();

        if (participantJson['type'] == 'team' &&
            participantJson['name'] == teamName) {
          teamIndex = i;
          break;
        }
      }

      if (teamIndex == -1) {
        throw ServerException('Team non trovato');
      }

      // Ottiene il team partecipante
      final teamParticipant =
          league.participants[teamIndex] as TeamParticipantModel;

      // Verifica che l'utente che richiede l'operazione sia un admin o il capitano del team
      final bool isAdmin = league.admins.contains(requestingUserId);
      final bool isCaptain = teamParticipant.captainId == requestingUserId;

      if (!isAdmin && !isCaptain) {
        throw ServerException(
            'Solo gli amministratori o il capitano del team possono rimuovere membri');
      }

      // Check if any of the users to remove are admins
      for (final userId in userIdsToRemove) {
        if (league.admins.contains(userId)) {
          throw ServerException(
              'Non puoi rimuovere un amministratore. Gli amministratori possono solo uscire autonomamente dalla lega.');
        }
      }

      // Assicurati che il capitano non venga rimosso
      if (userIdsToRemove.contains(teamParticipant.captainId)) {
        throw ServerException(
            'Il capitano non può essere rimosso dal team. Trasferisci prima il ruolo di capitano a un altro membro.');
      }

      // Filtra i membri per creare la lista aggiornata senza quelli da rimuovere
      final updatedMembers = teamParticipant.members
          .where((member) => !userIdsToRemove.contains(member.userId))
          .toList();

      // Verifica che rimanga almeno un membro nel team
      if (updatedMembers.isEmpty) {
        throw ServerException(
            'Non puoi rimuovere tutti i membri del team. Il team deve avere almeno un membro.');
      }

      // Crea il team aggiornato
      final updatedTeam = TeamParticipantModel(
        members: updatedMembers,
        captainId: teamParticipant.captainId,
        name: teamParticipant.name,
        points: teamParticipant.points,
        malusTotal: teamParticipant.malusTotal,
        bonusTotal: teamParticipant.bonusTotal,
        teamLogoUrl: teamParticipant.teamLogoUrl,
      );

      // Crea la lista aggiornata dei partecipanti
      final List<dynamic> updatedParticipants = [...league.participants];
      updatedParticipants[teamIndex] = updatedTeam;

      // Prepara i dati per l'aggiornamento
      final List<Map<String, dynamic>> participantsJson = updatedParticipants
          .map((p) => (p as ParticipantModel).toJson())
          .toList();

      // Aggiorna nel database
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {'participants': participantsJson},
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // A D D   A D M I N I S T R A T O R S
  @override
  Future<LeagueModel> addAdministrators({
    required LeagueModel league,
    required List<String> userIds,
  }) async {
    try {
      _checkAuthentication();

      // Get current admins and add new ones
      final List<String> updatedAdmins = [...league.admins, ...userIds];

      // Remove duplicates
      final List<String> uniqueAdmins = updatedAdmins.toSet().toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {'admins': uniqueAdmins},
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // R E M O V E   P A R T I C I P A N T S
  @override
  Future<LeagueModel> removeParticipants({
    required LeagueModel league,
    required List<String> participantIds,
    String? newCaptainId,
  }) async {
    try {
      _checkAuthentication();

      // Check if any of the users to remove are admins
      for (final userId in participantIds) {
        if (league.admins.contains(userId)) {
          throw ServerException(
              'Non puoi rimuovere un amministratore. Gli amministratori possono solo uscire autonomamente dalla lega.');
        }
      }

      // Handle both team and individual participants
      List<dynamic> updatedParticipants = [];

      for (final participant in league.participants) {
        if (participant is IndividualParticipantModel) {
          // For individual participants, check if their userId is in the remove list
          if (!participantIds.contains(participant.userId)) {
            updatedParticipants.add(participant);
          }
        } else if (participant is TeamParticipantModel) {
          // For team participants, check if captain is being removed
          final isCaptainBeingRemoved =
              participantIds.contains(participant.captainId);

          // Filter out members to remove
          final updatedMembers = participant.members
              .where((member) => !participantIds.contains(member.userId))
              .toList();

          // Check if the team will be left with at least one member
          if (updatedMembers.isEmpty) {
            throw ServerException(
                'Non puoi rimuovere tutti i membri del team. Il team deve avere almeno un membro.');
          }

          // If captain is being removed, validate that new captain exists in members
          String captainId = participant.captainId;

          if (isCaptainBeingRemoved) {
            // Ensure the new captain is in the updated members list
            final isNewCaptainValid = updatedMembers.any(
              (member) => member.userId == newCaptainId,
            );

            if (!isNewCaptainValid) {
              throw ServerException(
                  'Il nuovo capitano specificato non è un membro valido del team.');
            }

            captainId = newCaptainId!;
          }

          // If team still has members, add it with updated members
          updatedParticipants.add(TeamParticipantModel(
            members: updatedMembers,
            name: participant.name,
            points: participant.points,
            malusTotal: participant.malusTotal,
            bonusTotal: participant.bonusTotal,
            captainId: captainId,
            teamLogoUrl: participant.teamLogoUrl,
          ));
        }
      }

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'participants': updatedParticipants
              .map((p) => (p as ParticipantModel).toJson())
              .toList(),
        },
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // U P D A T E   L E A G U E   I N F O
  @override
  Future<LeagueModel> updateLeagueInfo({
    required LeagueModel league,
    String? name,
    String? description,
  }) async {
    try {
      _checkAuthentication();

      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;

      if (updateData.isEmpty) {
        // Nothing to update, return current league
        return league;
      }

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: updateData,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // U P L O A D   I M A G E   H E L P E R
  Future<String> _uploadImageToStorage({
    required String bucket,
    required String path,
    required File imageFile,
    required int expiresIn,
  }) async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$currentTime.jpg';
      final fullPath =
          path.endsWith('/') ? '$path$fileName' : '$path/$fileName';

      await supabaseClient.storage.from(bucket).upload(
            fullPath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Create a signed URL
      final signedUrl = await supabaseClient.storage
          .from(bucket)
          .createSignedUrl(fullPath, expiresIn);

      return signedUrl;
    } catch (e) {
      throw ServerException(
          'Errore durante l\'upload dell\'immagine: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // U P L O A D   I M A G E
  @override
  Future<String> uploadImage({
    required String leagueId,
    required File imageFile,
  }) async {
    try {
      final path = leagueId;
      return await _uploadImageToStorage(
        bucket: 'memories',
        path: path,
        imageFile: imageFile,
        expiresIn: 60 * 60 * 24 * 365, // 1 year
      );
    } catch (e) {
      throw ServerException(
          'Errore durante l\'upload dell\'immagine: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // U P L O A D   T E A M   L O G O
  @override
  Future<String> uploadTeamLogo({
    required String leagueId,
    required String teamName,
    required File imageFile,
  }) async {
    try {
      final path = '$leagueId/$teamName';
      return await _uploadImageToStorage(
        bucket: 'team-logos',
        path: path,
        imageFile: imageFile,
        expiresIn: 60 * 60 * 24 * 365, // 1 year
      );
    } catch (e) {
      throw ServerException(
          'Errore durante l\'upload del logo: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // U P D A T E   T E A M   L O G O
  @override
  Future<LeagueModel> updateTeamLogo({
    required LeagueModel league,
    required String teamName,
    required String logoUrl,
  }) async {
    try {
      // Find the team participant by name
      int targetIndex = -1;
      for (int i = 0; i < league.participants.length; i++) {
        final participant = league.participants[i];
        if (participant is TeamParticipantModel &&
            participant.name == teamName) {
          targetIndex = i;
          break;
        }
      }

      if (targetIndex == -1) {
        throw ServerException('Team non trovato');
      }

      // Get team participant and check if it already has a logo
      final teamParticipant =
          league.participants[targetIndex] as TeamParticipantModel;

      // If the team already has a logo, delete it from storage
      if (teamParticipant.teamLogoUrl != null &&
          teamParticipant.teamLogoUrl!.isNotEmpty) {
        await _deleteFileFromStorage(
          bucket: 'team-logos',
          url: teamParticipant.teamLogoUrl!,
        );
      }

      // Update the team with the new logo URL
      final updatedTeam = teamParticipant.copyWith(teamLogoUrl: logoUrl);

      // Update the participants list
      final updatedParticipants = List<dynamic>.from(league.participants);
      updatedParticipants[targetIndex] = updatedTeam;

      // Update the league
      return await _updateLeagueInDb(
        leagueId: league.id,
        updateData: {
          'participants': updatedParticipants
              .map((p) => (p as ParticipantModel).toJson())
              .toList()
        },
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  D E L E T E   F I L E   F R O M   S T O R A G E
  Future<void> _deleteFileFromStorage({
    required String bucket,
    required String url,
  }) async {
    try {
      // Extract the file path from the URL
      // URLs typically look like: https://xxx.supabase.co/storage/v1/object/public/bucket-name/path/to/file.jpg
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Find the bucket name in the path segments
      int bucketIndex = pathSegments.indexOf(bucket);
      if (bucketIndex == -1 || bucketIndex + 1 >= pathSegments.length) {
        debugPrint('⚠️ Could not extract file path from URL: $url');
        return;
      }

      // The file path is everything after the bucket name
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      debugPrint('🗑️ Deleting file from storage: $bucket/$filePath');

      // Delete the file
      await supabaseClient.storage.from(bucket).remove([filePath]);

      debugPrint('✅ File deleted successfully from storage');
    } catch (e) {
      // We don't want to throw an exception if this fails, just log it
      debugPrint('⚠️ Error deleting file from storage: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   C U R R E N T   U S E R   I D
  String? _getCurrentUserId() {
    final state = appUserCubit.state;

    if (state is AppUserIsLoggedIn) {
      return state.user.id;
    } else {
      return null;
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   C U R R E N T   U S E R   N A M E
  String? _getCurrentUserName() {
    final state = appUserCubit.state;

    if (state is AppUserIsLoggedIn) {
      return state.user.name;
    } else {
      return null;
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  C H E C K   A U T H E N T I C A T I O N
  String _checkAuthentication() {
    final currentUserId = _getCurrentUserId();

    if (currentUserId == null) {
      throw ServerException('Utente non autenticato');
    }
    return currentUserId;
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   L E A G U E   D A T A
  Future<LeagueModel> _getLeagueData(String leagueId) async {
    try {
      final response = await supabaseClient
          .from('leagues')
          .select()
          .eq('id', leagueId)
          .single();

      return _convertResponseToModel(response);
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  C O N V E R T   R E S P O N S E   T O   M O D E L
  LeagueModel _convertResponseToModel(Map<String, dynamic> response) {
    final jsonData = {
      ...response,
      'createdAt': response['created_at'],
      'isTeamBased': response['is_team_based'],
      if (response['invite_code'] != null)
        'inviteCode': response['invite_code'],
    };

    return LeagueModel.fromJson(jsonData);
  }

  // ------------------------------------------------
  // H E L P E R  -  U P D A T E   L E A G U E   I N   D B
  Future<LeagueModel> _updateLeagueInDb({
    required String leagueId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final updatedResponse = await supabaseClient
          .from('leagues')
          .update(updateData)
          .eq('id', leagueId)
          .select()
          .single();

      return _convertResponseToModel(updatedResponse);
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  F I N D   T A R G E T   P A R T I C I P A N T
  ParticipantModel? _findTargetParticipant({
    required LeagueModel league,
    required String targetUser,
  }) {
    for (final p in league.participants) {
      if (p is! ParticipantModel) continue;
      final participant = p;
      final json = participant.toJson();
      if (league.isTeamBased) {
        // For team-based leagues, targetUser is the team name
        if (json['type'] == 'team' && json['name'] == targetUser) {
          return participant;
        }
      } else {
        // For individual leagues, targetUser is the user ID
        if (json['type'] == 'individual' && json['userId'] == targetUser) {
          return participant;
        }
      }
    }
    return null;
  }

  // ------------------------------------------------
  // H E L P E R  -  C R E A T E   I N I T I A L   P A R T I C I P A N T
  ParticipantModel _createInitialParticipant({
    required bool isTeamBased,
    required String creatorId,
    required String creatorName,
  }) {
    if (isTeamBased) {
      return TeamParticipantModel(
        members: [
          SimpleParticipantModel(
            userId: creatorId,
            name: creatorName,
          ),
        ],
        captainId: creatorId,
        name: 'Team di $creatorName',
        points: 0,
        malusTotal: 0,
        bonusTotal: 0,
        teamLogoUrl: null,
      );
    } else {
      return IndividualParticipantModel(
        userId: creatorId,
        name: creatorName,
        points: 0,
        malusTotal: 0,
        bonusTotal: 0,
      );
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  C R E A T E   E V E N T   D A T A
  EventModel _createEventData({
    required String name,
    required int points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? description,
  }) {
    final eventId = uuid.v4();
    return EventModel(
      id: eventId,
      name: name,
      points: points,
      creatorId: creatorId,
      targetUser: targetUser,
      createdAt: DateTime.now(),
      type: type,
      description: description,
    );
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   U P D A T E D   E V E N T S   L I S T
  List<EventModel> _getUpdatedEventsList(
      List<dynamic> currentEvents, EventModel newEvent) {
    List<EventModel> updatedEvents = [
      ...currentEvents.map((e) => e as EventModel),
      newEvent,
    ];

    // If more than 10 events, remove oldest
    if (updatedEvents.length > 10) {
      updatedEvents.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      updatedEvents.removeAt(0);
    }

    return updatedEvents;
  }

  // ------------------------------------------------
  // H E L P E R  -  U P D A T E   P A R T I C I P A N T   S C O R E
  List<dynamic> _updateParticipantScore({
    required LeagueModel league,
    required ParticipantModel targetParticipant,
    required String targetUser,
    required int points,
  }) {
    final participantJson = targetParticipant.toJson();
    final updatedScore = targetParticipant.points + points;

    // Update bonus or malus totals
    int updatedBonusTotal = participantJson['bonusTotal'] ?? 0;
    int updatedMalusTotal = participantJson['malusTotal'] ?? 0;
    if (points > 0) {
      updatedBonusTotal += points;
    } else if (points < 0) {
      updatedMalusTotal += points.abs();
    }

    // Create updated participant data
    final updatedParticipantData = {
      ...participantJson,
      'points': updatedScore,
      'bonusTotal': updatedBonusTotal,
      'malusTotal': updatedMalusTotal,
    };

    // Replace the participant in the list
    return league.participants.map((p) {
      if (p is ParticipantModel) {
        final pJson = p.toJson();
        if (league.isTeamBased) {
          if (pJson['type'] == 'team' && pJson['name'] == targetUser) {
            return updatedParticipantData;
          }
        } else {
          if (pJson['type'] == 'individual' && pJson['userId'] == targetUser) {
            return updatedParticipantData;
          }
        }
      }
      return p is ParticipantModel ? p.toJson() : p;
    }).toList();
  }

  // ------------------------------------------------
  // H E L P E R  -  C R E A T E   M E M O R Y   D A T A
  MemoryModel _createMemoryData({
    required String imageUrl,
    required String text,
    required String userId,
    required String participantName,
    String? relatedEventId,
    String? eventName,
  }) {
    final memoryId = uuid.v4();
    return MemoryModel(
      id: memoryId,
      imageUrl: imageUrl,
      text: text,
      createdAt: DateTime.now(),
      userId: userId,
      participantName: participantName,
      relatedEventId: relatedEventId,
      eventName: eventName,
    );
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   U P D A T E D   E V E N T S   A F T E R   R E M O V A L
  List<Map<String, dynamic>> _getUpdatedEventsAfterRemoval(
      LeagueModel league, String eventId) {
    return league.events
        .where((e) => (e as EventModel).id != eventId)
        .map((e) => (e as EventModel).toJson())
        .toList();
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   U P D A T E D   P A R T I C I P A N T S   A F T E R   E V E N T   R E M O V A L
  List<dynamic> _getUpdatedParticipantsAfterEventRemoval(
      LeagueModel league, EventModel eventToRemove) {
    return league.participants.map((p) {
      final participantJson = (p as ParticipantModel).toJson();
      if ((participantJson['type'] == 'individual' &&
              participantJson['userId'] == eventToRemove.targetUser) ||
          (participantJson['type'] == 'team' &&
              (participantJson['members'] as List<dynamic>).any((member) =>
                  SimpleParticipantModel.fromJson(member).userId ==
                  eventToRemove.targetUser))) {
        final updatedScore = p.points - eventToRemove.points;

        // Update bonus or malus totals
        int updatedBonusTotal = participantJson['bonusTotal'] ?? 0;
        int updatedMalusTotal = participantJson['malusTotal'] ?? 0;
        if (eventToRemove.points > 0) {
          updatedBonusTotal -= eventToRemove.points;
        } else if (eventToRemove.points < 0) {
          updatedMalusTotal -= eventToRemove.points.abs();
        }

        return {
          ...participantJson,
          'points': updatedScore,
          'bonusTotal': updatedBonusTotal,
          'malusTotal': updatedMalusTotal,
        };
      }
      return participantJson;
    }).toList();
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   U P D A T E D   M E M O R I E S   A F T E R   R E M O V A L
  List<Map<String, dynamic>> _getUpdatedMemoriesAfterRemoval(
    LeagueModel league,
    String memoryId,
  ) {
    return league.memories
        .where((m) => (m as MemoryModel).id != memoryId)
        .map((m) => (m as MemoryModel).toJson())
        .toList();
  }

  // ------------------------------------------------
  // H E L P E R  -  F I N D   U S E R   T E A M   I N D E X
  int _findUserTeamIndex(LeagueModel league, String userId) {
    for (int i = 0; i < league.participants.length; i++) {
      final participant = league.participants[i] as ParticipantModel;
      if (participant is TeamParticipantModel) {
        // Check if userId is in the members list
        if (participant.members.any((member) => member.userId == userId)) {
          return i;
        }
      }
    }
    return -1;
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   U P D A T E D   P A R T I C I P A N T S   W I T H   N E W   T E A M   N A M E
  List<dynamic> _getUpdatedParticipantsWithNewTeamName(
      LeagueModel league, String userId, String newName) {
    return league.participants.map((p) {
      final participant = p as ParticipantModel;
      if (participant is TeamParticipantModel &&
          participant.members.any((member) => member.userId == userId)) {
        return {
          ...participant.toJson(),
          'name': newName,
        };
      }
      return participant.toJson();
    }).toList();
  }

  // ------------------------------------------------
  // H E L P E R  -  I N S E R T   R U L E   A N D   R E I N D E X   I D S
  List<RuleModel> _insertRule({
    required List<RuleModel> existingRules,
    required RuleModel newRule,
    required RuleType ruleType,
  }) {
    // Separate rules by type
    final List<RuleModel> bonusRules =
        existingRules.where((r) => r.type == RuleType.bonus).toList();

    final List<RuleModel> malusRules =
        existingRules.where((r) => r.type == RuleType.malus).toList();

    // Add the new rule to the appropriate list
    if (ruleType == RuleType.bonus) {
      bonusRules.add(newRule);
    } else {
      malusRules.add(newRule);
    }

    // Combine the rules in the right order (bonus first, then malus)
    return [...bonusRules, ...malusRules];
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   P A R T I C I P A N T   N A M E   B Y   U S E R   I D
  String _getParticipantNameByUserId(LeagueModel league, String userId) {
    for (final participant in league.participants) {
      final participantJson = (participant as ParticipantModel).toJson();

      if (participantJson['type'] == 'individual' &&
          participantJson['userId'] == userId) {
        return participantJson['name'] as String;
      } else if (participantJson['type'] == 'team') {
        final members = (participantJson['members'] as List<dynamic>?) ?? [];
        for (final memberJson in members) {
          if (memberJson['userId'] == userId) {
            return "${participantJson['name']} - ${memberJson['name']}";
          }
        }
      }
    }
    return "Utente";
  }
}
