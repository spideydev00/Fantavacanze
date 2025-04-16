import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/event_model.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/memory_model.dart';
import 'package:fantavacanze_official/features/league/data/models/participant_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class LeagueRemoteDataSource {
  Future<LeagueModel> createLeague({
    required String name,
    required String description,
    required bool isTeamBased,
    required List<String> admins,
    required List<Map<String, dynamic>> rules,
  });

  Future<LeagueModel> getLeague(String leagueId);

  Future<List<LeagueModel>> getUserLeagues();

  Future<LeagueModel> updateLeague({
    required String leagueId,
    String? name,
    String? description,
  });
  Future<void> deleteLeague(String leagueId);

  Future<LeagueModel> joinLeague({
    required String inviteCode,
    required String userId,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  });

  Future<LeagueModel> exitLeague({
    required String leagueId,
    required String userId,
  });

  Future<LeagueModel> updateTeamName({
    required String leagueId,
    required String userId,
    required String newName,
  });

  Future<LeagueModel> addEvent({
    required String leagueId,
    required String name,
    required int points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? description,
  });

  Future<LeagueModel> removeEvent({
    required String leagueId,
    required String eventId,
  });

  Future<LeagueModel> addMemory({
    required String leagueId,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
  });

  Future<LeagueModel> removeMemory({
    required String leagueId,
    required String memoryId,
  });

  Future<List<RuleModel>> getRules({required String mode});

  Future<LeagueModel> updateRule({
    required String leagueId,
    required Map<String, dynamic> rule,
  });

  Future<LeagueModel> deleteRule({
    required String leagueId,
    required int ruleId,
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
    required String description,
    required bool isTeamBased,
    required List<String> admins,
    required List<Map<String, dynamic>> rules,
  }) async {
    try {
      final String leagueId = uuid.v4();
      final String inviteCode = uuid.v4().substring(0, 10);

      // Get creator info
      final creatorId = _checkAuthentication();
      final creatorName = _getCurrentUserName();

      if (creatorName == null) {
        throw ServerException('Utente non autenticato');
      }

      // Create initial participant
      final Map<String, dynamic> initialParticipant = _createInitialParticipant(
        isTeamBased: isTeamBased,
        creatorId: creatorId,
        creatorName: creatorName,
      );

      // FIXED: Assign unique incrementing IDs to each rule
      final List<Map<String, dynamic>> processedRules = [];

      // Process each rule and assign a unique ID (starting from 1)
      for (int i = 0; i < rules.length; i++) {
        final rule = Map<String, dynamic>.from(rules[i]);

        // Assign ID (starting from 1, not 0)
        rule['id'] = i + 1;

        // Ensure rule_type is consistent (not 'type')
        rule['rule_type'] = rule['type'] ?? rule['rule_type'];
        rule.remove('type'); // Remove 'type' if it exists

        processedRules.add(rule);
      }

      final leagueData = {
        'id': leagueId,
        'invite_code': inviteCode,
        'admins': admins,
        'name': name,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
        'rules': processedRules, // Use processed rules with unique IDs
        'participants': [initialParticipant],
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
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
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
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // U P D A T E   L E A G U E
  @override
  Future<LeagueModel> updateLeague({
    required String leagueId,
    String? name,
    String? description,
  }) async {
    try {
      // Prepare update data
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
      // Admin checks handled by app-wide admin checks
      await supabaseClient.from('leagues').delete().eq('id', leagueId);
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // J O I N   L E A G U E
  @override
  Future<LeagueModel> joinLeague({
    required String inviteCode,
    required String userId,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  }) async {
    try {
      // Get leagues with this invite code
      final leagueResponse = await supabaseClient
          .from('leagues')
          .select()
          .eq('invite_code', inviteCode);

      if (leagueResponse.isEmpty) {
        throw ServerException(
            'Nessuna lega trovata con questo codice di invito');
      }

      // Determine which league to join
      final result = _determineLeagueToJoin(
        leagueResponse: leagueResponse,
        specificLeagueId: specificLeagueId,
      );
      final leagueData = result['leagueData'];
      final leagueId = result['leagueId'];

      // Convert to our model format
      final league = _convertResponseToModel(leagueData);

      // Check if user is already a participant
      _checkIfUserIsAlreadyParticipant(league, userId);

      // Create participant data
      final Map<String, dynamic> participantData = _createParticipantData(
        league: league,
        userId: userId,
        teamName: teamName,
        teamMembers: teamMembers,
      );

      // Update the league with the new participant
      final List<dynamic> updatedParticipants = [
        ...league.participants.map((p) => (p as ParticipantModel).toJson()),
        participantData,
      ];

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: leagueId,
        updateData: {'participants': updatedParticipants},
      );
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ------------------------------------------------
  // E X I T   L E A G U E
  @override
  Future<LeagueModel> exitLeague({
    required String leagueId,
    required String userId,
  }) async {
    try {
      // Get the current league data
      final league = await _getLeagueData(leagueId);

      // Check if user is an admin
      if (league.admins.contains(userId)) {
        await _handleAdminExit(leagueId, userId, league);
      }

      // Remove user from participants
      final updatedParticipants =
          _getUpdatedParticipantsAfterExit(league, userId);

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: leagueId,
        updateData: {'participants': updatedParticipants},
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // U P D A T E   T E A M   N A M E
  @override
  Future<LeagueModel> updateTeamName({
    required String leagueId,
    required String userId,
    required String newName,
  }) async {
    try {
      // Get the current league data
      final league = await _getLeagueData(leagueId);

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
        leagueId: leagueId,
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
    required String leagueId,
    required String name,
    required int points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? description,
  }) async {
    try {
      // Get the current league data
      final league = await _getLeagueData(leagueId);

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
        leagueId: leagueId,
        updateData: {
          'events': updatedEvents,
          'participants': updatedParticipants,
        },
      );
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // R E M O V E   E V E N T
  @override
  Future<LeagueModel> removeEvent({
    required String leagueId,
    required String eventId,
  }) async {
    try {
      _checkAuthentication();

      // Get the current league data
      final league = await _getLeagueData(leagueId);

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
        leagueId: leagueId,
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
    required String leagueId,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
  }) async {
    try {
      // Get the current league data
      final league = await _getLeagueData(leagueId);

      // Create new memory
      final memoryData = _createMemoryData(
        imageUrl: imageUrl,
        text: text,
        userId: userId,
        relatedEventId: relatedEventId,
      );

      // Add new memory to the list
      final updatedMemories = [
        ...league.memories.map((m) => (m as MemoryModel).toJson()),
        memoryData,
      ];

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: leagueId,
        updateData: {'memories': updatedMemories},
      );
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // R E M O V E   M E M O R Y
  @override
  Future<LeagueModel> removeMemory({
    required String leagueId,
    required String memoryId,
  }) async {
    try {
      final currentUserId = _checkAuthentication();

      // Get the current league data
      final league = await _getLeagueData(leagueId);

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

      // Remove the memory
      final updatedMemories = _getUpdatedMemoriesAfterRemoval(league, memoryId);

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: leagueId,
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
      final response = await supabaseClient
          .from(tableName)
          .select()
          .order('id', ascending: true);

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
    required String leagueId,
    required Map<String, dynamic> rule,
  }) async {
    try {
      // Get current league to access its rules
      final league = await _getLeagueData(leagueId);

      // Find the rule to update by ID
      final ruleId = rule['id'];

      // Create updated rules list
      final updatedRules = league.rules.map((r) {
        if (r.id == ruleId) {
          // Get the proper type
          final String typeStr = rule['type']?.toString().toLowerCase() ?? '';
          final RuleType type =
              typeStr == 'malus' ? RuleType.malus : RuleType.bonus;

          // Get points value and handle sign properly
          double pointsValue = 0.0;
          if (rule['points'] is int) {
            pointsValue = (rule['points'] as int).toDouble();
          } else if (rule['points'] is double) {
            pointsValue = rule['points'] as double;
          } else if (rule['points'] is String) {
            pointsValue = double.tryParse(rule['points'] as String) ?? 0.0;
          }

          // Create new RuleModel with updated values
          return RuleModel(
            id: ruleId,
            name: rule['name'],
            points: pointsValue,
            type: type,
          );
        }
        return r;
      }).toList();

      // Format rules for database update
      final List<Map<String, dynamic>> rulesJson =
          updatedRules.map((r) => (r as RuleModel).toJson()).toList();

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: leagueId,
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
    required String leagueId,
    required int ruleId,
  }) async {
    try {
      // Get current league to access its rules
      final league = await _getLeagueData(leagueId);

      // Filter out the rule to delete
      final remainingRules = league.rules.where((r) => r.id != ruleId).toList();

      // Reindex the remaining rules to ensure sequential IDs
      final updatedRules = <Map<String, dynamic>>[];
      for (int i = 0; i < remainingRules.length; i++) {
        final rule = (remainingRules[i] as RuleModel).toJson();
        rule['id'] = i + 1; // Reassign IDs starting from 1
        updatedRules.add(rule);
      }

      // Update in Supabase
      return await _updateLeagueInDb(
        leagueId: leagueId,
        updateData: {'rules': updatedRules},
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Si è verificato un errore: ${e.toString()}');
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
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
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
    } on PostgrestException catch (e) {
      throw ServerException('Errore: ${e.message}');
    } catch (e) {
      throw ServerException('Si è verificato un errore: ${e.toString()}');
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  C R E A T E   I N I T I A L   P A R T I C I P A N T
  Map<String, dynamic> _createInitialParticipant({
    required bool isTeamBased,
    required String creatorId,
    required String creatorName,
  }) {
    if (isTeamBased) {
      return {
        'type': 'team',
        'userIds': [creatorId],
        'name': '$creatorName Team', // Default team name
        'score': 0,
        'malusTotal': 0,
        'bonusTotal': 0,
      };
    } else {
      return {
        'type': 'individual',
        'userId': creatorId,
        'name': creatorName,
        'score': 0,
        'malusTotal': 0,
        'bonusTotal': 0,
      };
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  D E T E R M I N E   L E A G U E   T O   J O I N
  Map<String, dynamic> _determineLeagueToJoin({
    required List<dynamic> leagueResponse,
    String? specificLeagueId,
  }) {
    if (specificLeagueId != null) {
      // If user has selected a specific league from multiple options
      final leagueIndex =
          leagueResponse.indexWhere((l) => l['id'] == specificLeagueId);
      if (leagueIndex == -1) {
        throw ServerException('Lega selezionata non trovata');
      }
      return {
        'leagueData': leagueResponse[leagueIndex],
        'leagueId': specificLeagueId,
      };
    } else if (leagueResponse.length > 1) {
      // Present multiple leagues to the user to choose from
      throw ServerException(
        'Più leghe trovate con questo codice. Selezionane una:',
        data: leagueResponse
            .map((league) => {
                  'id': league['id'],
                  'name': league['name'],
                  'description': league['description'],
                })
            .toList(),
      );
    } else {
      // Only one league found with this code
      return {
        'leagueData': leagueResponse[0],
        'leagueId': leagueResponse[0]['id'],
      };
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  C H E C K   I F   U S E R   I S   A L R E A D Y   P A R T I C I P A N T
  void _checkIfUserIsAlreadyParticipant(LeagueModel league, String userId) {
    final isAlreadyParticipant = league.participants.any((p) =>
        (p is ParticipantModel &&
            p.toJson()['type'] == 'individual' &&
            p.toJson()['userId'] == userId) ||
        (p is ParticipantModel &&
            p.toJson()['type'] == 'team' &&
            (p.toJson()['userIds'] as List<dynamic>).contains(userId)));

    if (isAlreadyParticipant) {
      throw ServerException('L\'utente è già un partecipante di questa lega');
    }
  }

  // ------------------------------------------------
  // H E L P E R  -  C R E A T E   P A R T I C I P A N T   D A T A
  Map<String, dynamic> _createParticipantData({
    required LeagueModel league,
    required String userId,
    String? teamName,
    List<String>? teamMembers,
  }) {
    if (league.isTeamBased) {
      if (teamName == null) {
        throw ServerException(
            'Il nome del team è obbligatorio per le leghe basate su squadre');
      }

      return {
        'type': 'team',
        'userIds': teamMembers ?? [userId],
        'name': teamName,
        'score': 0,
        'malusTotal': 0,
        'bonusTotal': 0,
      };
    } else {
      final currentUserName = _getCurrentUserName();
      if (currentUserName == null) {
        throw ServerException('Utente non autenticato');
      }

      return {
        'type': 'individual',
        'userId': userId,
        'name': currentUserName,
        'score': 0,
        'malusTotal': 0,
        'bonusTotal': 0,
      };
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
  // H E L P E R  -  C R E A T E   E V E N T   D A T A
  Map<String, dynamic> _createEventData({
    required String name,
    required int points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    String? description,
  }) {
    final eventId = uuid.v4();

    // Convert RuleType enum to string safely
    final String typeString = type.toString().split('.').last;

    return {
      'id': eventId,
      'name': name,
      'points': points,
      'creatorId': creatorId,
      'targetUser': targetUser,
      'createdAt': DateTime.now().toIso8601String(),
      'type': typeString,
      'description': description,
    };
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   U P D A T E D   E V E N T S   L I S T
  List<Map<String, dynamic>> _getUpdatedEventsList(
      List<dynamic> currentEvents, Map<String, dynamic> newEvent) {
    List<Map<String, dynamic>> updatedEvents = [
      ...currentEvents.map((e) => (e as EventModel).toJson()),
      newEvent,
    ];

    // If more than 10 events, remove oldest
    if (updatedEvents.length > 10) {
      updatedEvents.sort((a, b) => DateTime.parse(a['createdAt'])
          .compareTo(DateTime.parse(b['createdAt'])));
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
      'score': updatedScore,
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
  Map<String, dynamic> _createMemoryData({
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
  }) {
    final memoryId = uuid.v4();
    return {
      'id': memoryId,
      'imageUrl': imageUrl,
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
      'userId': userId,
      'relatedEventId': relatedEventId,
    };
  }

  // ------------------------------------------------
  // H E L P E R  -  H A N D L E   A D M I N   E X I T
  Future<void> _handleAdminExit(
      String leagueId, String userId, LeagueModel league) async {
    // If this is the only admin, don't allow exit
    if (league.admins.length == 1) {
      throw ServerException(
          'Impossibile uscire dalla lega: sei l\'unico amministratore. Trasferisci i diritti di amministratore o elimina la lega');
    }

    // Update admins list
    final updatedAdmins = [...league.admins];
    updatedAdmins.remove(userId);

    await supabaseClient.from('leagues').update({
      'admins': updatedAdmins,
    }).eq('id', leagueId);
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   U P D A T E D   P A R T I C I P A N T S   A F T E R   E X I T
  List<Map<String, dynamic>> _getUpdatedParticipantsAfterExit(
      LeagueModel league, String userId) {
    return league.participants
        .where((p) {
          final participantJson = (p as ParticipantModel).toJson();
          if (participantJson['type'] == 'individual') {
            return participantJson['userId'] != userId;
          } else {
            // For teams, we need to check if user is in the team
            final userIds = List<String>.from(participantJson['userIds']);
            // If user is in team:
            if (userIds.contains(userId)) {
              // If they're the only member, remove the whole team
              if (userIds.length == 1) {
                return false;
              }
              // Otherwise, keep the team but remove the user below
              userIds.remove(userId);
              participantJson['userIds'] = userIds;
            }
            return true;
          }
        })
        .map((p) => (p as ParticipantModel).toJson())
        .toList();
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
              (participantJson['userIds'] as List<dynamic>)
                  .contains(eventToRemove.targetUser))) {
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
          'score': updatedScore,
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
      LeagueModel league, String memoryId) {
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
      final participantJson = participant.toJson();

      if (participantJson['type'] == 'team' &&
          (participantJson['userIds'] as List<dynamic>).contains(userId)) {
        return i;
      }
    }
    return -1;
  }

  // ------------------------------------------------
  // H E L P E R  -  G E T   U P D A T E D   P A R T I C I P A N T S   W I T H   N E W   T E A M   N A M E
  List<dynamic> _getUpdatedParticipantsWithNewTeamName(
      LeagueModel league, String userId, String newName) {
    return league.participants.map((p) {
      final participantJson = (p as ParticipantModel).toJson();
      if (participantJson['type'] == 'team' &&
          (participantJson['userIds'] as List<dynamic>).contains(userId)) {
        return {
          ...participantJson,
          'name': newName,
        };
      }
      return participantJson;
    }).toList();
  }
}
