import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/daily_challenge_model/daily_challenge_model.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model/note_model.dart';
import 'package:fantavacanze_official/features/league/data/models/notification_model/notification/notification_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model/rule_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/entities/note.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/league/data/datasources/league_local_data_source.dart';
import 'package:fantavacanze_official/features/league/data/datasources/league_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'dart:io';

class LeagueRepositoryImpl implements LeagueRepository {
  final LeagueRemoteDataSource remoteDataSource;
  final LeagueLocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  LeagueRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, League>> createLeague({
    required String name,
    String? description,
    required bool isTeamBased,
    required List<Rule> rules,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      // Convert Rule objects to RuleModel objects
      final List<RuleModel> ruleModels = rules
          .map((rule) => RuleModel(
                createdAt: rule.createdAt,
                name: rule.name,
                type: rule.type,
                points: rule.points,
              ))
          .toList();

      final league = await remoteDataSource.createLeague(
        name: name,
        description: description ?? "",
        isTeamBased: isTeamBased,
        rules: ruleModels,
      );

      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> getLeague(String leagueId) async {
    try {
      if (!await connectionChecker.isConnected) {
        // Try to get league from cache when offline
        final cachedLeague = await localDataSource.getCachedLeague(leagueId);
        if (cachedLeague != null) {
          return Right(cachedLeague);
        }
        return Left(
          Failure("Nessuna connessione e nessun dato nella cache."),
        );
      }

      // Get from remote and cache
      final league = await remoteDataSource.getLeague(leagueId);
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      // If server error, try to get from cache
      try {
        final cachedLeague = await localDataSource.getCachedLeague(leagueId);
        if (cachedLeague != null) {
          return Right(cachedLeague);
        }
      } catch (_) {}
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, List<League>>> getUserLeagues() async {
    try {
      if (!await connectionChecker.isConnected) {
        // Return cached leagues when offline
        final cachedLeagues = await localDataSource.getCachedLeagues();
        return Right(cachedLeagues);
      }

      // Get from remote and cache
      final leagues = await remoteDataSource.getUserLeagues();

      await localDataSource.cacheLeagues(leagues);

      return Right(leagues);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> updateLeagueNameOrDescription({
    required String leagueId,
    String? name,
    String? description,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
            "Nessuna connessione ad internet, riprova appena sarai connesso.",
          ),
        );
      }

      final league = await remoteDataSource.updateLeagueNameOrDescription(
        leagueId: leagueId,
        name: name,
        description: description,
      );

      // Update cache
      await localDataSource.cacheLeague(league);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLeague(String leagueId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            "Nessuna connessione ad internet, riprova appena sarai connesso."));
      }

      await remoteDataSource.deleteLeague(leagueId);

      // Remove the league from cache as well
      await localDataSource.removeLeagueFromCache(leagueId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, List<League>>> searchLeague(
      {required String inviteCode}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }
      final leagues =
          await remoteDataSource.searchLeague(inviteCode: inviteCode);
      return Right(leagues);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, League>> joinLeague({
    required String inviteCode,
    String? teamName,
    List<String>? teamMembers,
    String? specificLeagueId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final league = await remoteDataSource.joinLeague(
        inviteCode: inviteCode,
        teamName: teamName,
        teamMembers: teamMembers,
        specificLeagueId: specificLeagueId,
      );

      // Cache the joined league
      await localDataSource.cacheLeague(league);

      // Also update the user leagues cache
      final userLeagues = await remoteDataSource.getUserLeagues();
      await localDataSource.cacheLeagues(userLeagues);

      return Right(league);
    } on ServerException catch (e) {
      return Left(Failure(e.message, data: e.data));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> exitLeague({
    required League league,
    required String userId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      await remoteDataSource.exitLeague(
        league: league as LeagueModel,
        userId: userId,
      );

      await localDataSource.removeLeagueFromCache(league.id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> updateTeamName({
    required League league,
    required String userId,
    required String newName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.updateTeamName(
        league: league as LeagueModel,
        userId: userId,
        newName: newName,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> addEvent({
    required League league,
    required String name,
    required double points,
    required String creatorId,
    required String targetUser,
    required RuleType type,
    required bool isTeamMember,
    String? description,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.addEvent(
        league: league as LeagueModel,
        name: name,
        points: points,
        creatorId: creatorId,
        targetUser: targetUser,
        type: type,
        description: description,
        isTeamMember: isTeamMember,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> addMemory({
    required League league,
    required String imageUrl,
    required String text,
    required String userId,
    String? relatedEventId,
    String? eventName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.addMemory(
        league: league as LeagueModel,
        imageUrl: imageUrl,
        text: text,
        userId: userId,
        relatedEventId: relatedEventId,
        eventName: eventName,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> removeMemory({
    required League league,
    required String memoryId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.removeMemory(
        league: league as LeagueModel,
        memoryId: memoryId,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> updateRule({
    required League league,
    required Rule rule,
    String? originalRuleName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      // Properly convert Rule to RuleModel
      final ruleModel = RuleModel(
        createdAt: rule.createdAt,
        name: rule.name,
        type: rule.type,
        points: rule.points,
      );

      final updatedLeague = await remoteDataSource.updateRule(
        league: league as LeagueModel,
        rule: ruleModel,
        originalRuleName: originalRuleName,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> deleteRule({
    required League league,
    required String ruleName,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.deleteRule(
        league: league as LeagueModel,
        ruleName: ruleName,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> addRule({
    required League league,
    required Rule rule,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final ruleModel = RuleModel(
        createdAt: rule.createdAt,
        name: rule.name,
        type: rule.type,
        points: rule.points,
      );

      final updatedLeague = await remoteDataSource.addRule(
        league: league as LeagueModel,
        rule: ruleModel,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> removeTeamParticipants({
    required League league,
    required String teamName,
    required List<String> userIdsToRemove,
    required String requestingUserId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final leagueModel = await remoteDataSource.removeTeamParticipants(
        league: league as LeagueModel,
        teamName: teamName,
        userIdsToRemove: userIdsToRemove,
        requestingUserId: requestingUserId,
      );

      // Aggiorna la versione in cache
      await localDataSource.cacheLeague(leagueModel);

      return Right(leagueModel);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalCache() async {
    try {
      await localDataSource.clearCache();

      return const Right(null);
    } on CacheException catch (e) {
      return Left(Failure('Errore nella pulizia della cache: ${e.toString()}'));
    }
  }

  // Note operations
  @override
  Future<Either<Failure, List<NoteModel>>> getNotes(String leagueId) async {
    try {
      final notes = await localDataSource.getNotes(leagueId);
      return Right(notes);
    } on CacheException catch (e) {
      final errorMessage = 'Errore nel recuperare le note: ${e.message}';
      return Left(Failure(errorMessage));
    } catch (e) {
      final errorMessage =
          'Errore imprevisto nel recuperare le note: ${e.toString()}';
      return Left(Failure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> saveNote(
    String leagueId, // This leagueId parameter is from the event
    Note note, // This is the Note entity from the event
  ) async {
    try {
      // Explicitly convert the Note entity to NoteModel
      final noteModel = NoteModel(
        id: note.id,
        participantId: note.participantId,
        participantName: note.participantName,
        content: note.content,
        createdAt: note.createdAt,
        leagueId: note.leagueId, // Use leagueId from the note entity itself
      );

      // Pass the created noteModel and its leagueId to the local data source.
      // The localDataSource.saveNote uses the second parameter for its key generation.
      await localDataSource.saveNote(noteModel, noteModel.leagueId);
      return const Right(null);
    } on CacheException catch (e) {
      final errorMessage = 'Errore nel salvare la nota: ${e.message}';
      return Left(Failure(errorMessage));
    } catch (e) {
      // Catch any other potential errors during conversion or saving
      final errorMessage =
          'Errore imprevisto nel salvare la nota: ${e.toString()}';
      return Left(Failure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(
      String leagueId, String noteId) async {
    try {
      await localDataSource.deleteNote(
        noteId,
        leagueId,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(Failure('Errore nel cancellare la nota: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage({
    required String leagueId,
    required File imageFile,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final imageUrl = await remoteDataSource.uploadImage(
        leagueId: leagueId,
        imageFile: imageFile,
      );

      return Right(imageUrl);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(
          'Errore durante il caricamento dell\'immagine: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadTeamLogo({
    required String leagueId,
    required String teamName,
    required File imageFile,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final logoUrl = await remoteDataSource.uploadTeamLogo(
        leagueId: leagueId,
        teamName: teamName,
        imageFile: imageFile,
      );

      return Right(logoUrl);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(
          Failure('Errore durante il caricamento del logo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, League>> updateTeamLogo({
    required League league,
    required String teamName,
    required String logoUrl,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.updateTeamLogo(
        league: league as LeagueModel,
        teamName: teamName,
        logoUrl: logoUrl,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    } catch (e) {
      return Left(
          Failure('Errore durante l\'aggiornamento del logo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, League>> addAdministrators({
    required League league,
    required List<String> userIds,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.addAdministrators(
        league: league as LeagueModel,
        userIds: userIds,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> removeParticipants({
    required League league,
    required List<String> participantIds,
    String? newCaptainId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            "Nessuna connessione ad internet, riprova appena sarai connesso."));
      }

      final updatedLeague = await remoteDataSource.removeParticipants(
        league: league as LeagueModel,
        participantIds: participantIds,
        newCaptainId: newCaptainId,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, League>> updateLeagueInfo({
    required League league,
    String? name,
    String? description,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final updatedLeague = await remoteDataSource.updateLeagueInfo(
        league: league as LeagueModel,
        name: name,
        description: description,
      );

      // Update cache
      await localDataSource.cacheLeague(updatedLeague);

      return Right(updatedLeague);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  // -----------------------------------------------------
  // D A I L Y   C H A L L E N G E S   O P E R A T I O N S
  // -----------------------------------------------------

  @override
  Future<Either<Failure, List<DailyChallenge>>> getDailyChallenges({
    required String userId,
    required String leagueId,
  }) async {
    try {
      final cachedChallenges =
          await localDataSource.getCachedDailyChallenges(leagueId);

      if (cachedChallenges.isNotEmpty) {
        // Check if cached challenges need refresh (passed 7 AM)
        final now = DateTime.now();
        final today7AM = DateTime(now.year, now.month, now.day, 7, 0);

        // Get the first challenge to check its creation date
        final challenge = cachedChallenges.first;

        // If it's past 7 AM and the challenge was created before today at 7 AM,
        // we need to refresh the challenges
        bool needsRefresh =
            now.isAfter(today7AM) && challenge.createdAt.isBefore(today7AM);

        if (!needsRefresh) {
          return Right(cachedChallenges);
        } else if (!await connectionChecker.isConnected) {
          // If we need refresh but have no connection, use cache anyway
          return Right(cachedChallenges);
        }
      } else if (!await connectionChecker.isConnected) {
        return Left(
            Failure('❌ Nessuna connessione e nessun dato nella cache.'));
      }

      // Get from remote and cache
      final challenges = await remoteDataSource.getDailyChallenges(
        userId: userId,
        leagueId: leagueId,
      );

      await localDataSource.cacheDailyChallenges(challenges, leagueId);

      return Right(challenges);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> unlockDailyChallenge({
    required String challengeId,
    required String leagueId,
    required bool isUnlocked,
    int primaryPosition = 2,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      final res = await remoteDataSource.unlockDailyChallenge(
        challengeId: challengeId,
        isUnlocked: isUnlocked,
        leagueId: leagueId,
        primaryPosition: primaryPosition,
      );

      // Update the challenges in the cache
      final cachedChallenges =
          await localDataSource.getCachedDailyChallenges(leagueId);

      // Calculate substitute position
      final substitutePosition = primaryPosition + 3;

      // Update both the primary challenge by ID and any challenge at the substitute position
      final updatedChallenges = cachedChallenges.map((cachedChallenge) {
        // Update specific challenge by ID
        if (cachedChallenge.id == challengeId) {
          return cachedChallenge.copyWith(isUnlocked: isUnlocked);
        }

        // Also update the substitute challenge at position + 3
        if (cachedChallenge.position == substitutePosition) {
          return cachedChallenge.copyWith(isUnlocked: isUnlocked);
        }

        return cachedChallenge;
      }).toList();

      await localDataSource.cacheDailyChallenges(updatedChallenges, leagueId);

      return Right(res);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendChallengeNotification({
    required League league,
    required DailyChallenge challenge,
    required String userId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      await remoteDataSource.sendChallengeNotification(
        league: league as LeagueModel,
        challenge: challenge as DailyChallengeModel,
        userId: userId,
      );

      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> markChallengeAsCompleted({
    required DailyChallenge challenge,
    required League league,
    required String userId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      await remoteDataSource.markChallengeAsCompleted(
        challenge: challenge as DailyChallengeModel,
        userId: userId,
        league: league as LeagueModel,
      );

      // Update the challenge in the cache
      final cachedChallenges =
          await localDataSource.getCachedDailyChallenges(league.id);

      final updatedChallenges = cachedChallenges.map((cachedChallenge) {
        if (cachedChallenge.id == challenge.id) {
          return cachedChallenge.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }
        return cachedChallenge;
      }).toList();

      await localDataSource.cacheDailyChallenges(updatedChallenges, league.id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateChallengeRefreshStatus({
    required String challengeId,
    required String userId,
    required bool isRefreshed,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      // 1. Update on the server
      await remoteDataSource.updateChallengeRefreshStatus(
        challengeId: challengeId,
        userId: userId,
        isRefreshed: isRefreshed,
      );

      // 2. Find which league this challenge belongs to
      final leagueId =
          await localDataSource.findLeagueIdForChallenge(challengeId);

      if (leagueId.isNotEmpty) {
        // 3. Update in cache
        await localDataSource.updateCachedChallenge(
            challengeId, leagueId, isRefreshed);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    try {
      // Prima prova a prendere le notifiche dalla cache
      final cachedNotifications =
          await localDataSource.getCachedNotifications();

      // Esegui pulizia delle notifiche vecchie
      await localDataSource.cleanupOldNotifications();

      // Se ci sono notifiche nella cache, restituiscile
      if (cachedNotifications.isNotEmpty) {
        return Right(cachedNotifications);
      }

      // Ottieni le notifiche dal server
      final notifications = await remoteDataSource.getNotifications();

      // Salva le notifiche nella cache
      await localDataSource.cacheNotifications(notifications);

      return Right(notifications);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      // Update on the server
      await remoteDataSource.markAsRead(notificationId);

      // Update in cache
      await localDataSource.markNotificationAsRead(notificationId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
      String notificationId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      // Delete from server
      await remoteDataSource.deleteNotification(notificationId);

      // Delete from cache
      await localDataSource.deleteNotificationFromCache(notificationId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> approveDailyChallenge(
      String notificationId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      // Approve on server
      await remoteDataSource.approveDailyChallenge(notificationId);

      // Delete from cache since it's been processed
      await localDataSource.deleteNotificationFromCache(notificationId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectDailyChallenge(
    String notificationId,
    String challengeId,
  ) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure(
            'Nessuna connessione ad internet, riprova appena sarai connesso.'));
      }

      // Reject on server
      await remoteDataSource.rejectDailyChallenge(notificationId, challengeId);

      // Delete from cache since it's been processed
      await localDataSource.deleteNotificationFromCache(notificationId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure('Errore nella cache: ${e.message}'));
    }
  }

  @override
  Either<Failure, Stream<NotificationModel>> listenToNotification() {
    try {
      final stream = remoteDataSource.listenToNotification();

      stream.listen((notificationModel) async {
        // Salva direttamente nella cache
        await localDataSource.cacheNotification(notificationModel);
      });

      return Right(stream);
    } on ServerException catch (e) {
      return Left(
          Failure('Errore nell\'ascolto delle notifiche: ${e.message}'));
    }
  }
}
