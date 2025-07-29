import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/note_model/note_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model/rule_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/note.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/league/data/datasources/local/local_data_source.dart';
import 'package:fantavacanze_official/features/league/data/datasources/remote/league_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'dart:io';

class LeagueRepositoryImpl implements LeagueRepository {
  final LeagueRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
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
  Future<Either<Failure, League>> removeEvent({
    required League league,
    required String eventId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(Failure('Nessuna connessione internet'));
      }

      final updatedLeague = await remoteDataSource.removeEvent(
        league: league as LeagueModel,
        eventId: eventId,
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
  Future<Either<Failure, String>> uploadMedia({
    required String leagueId,
    required File mediaFile,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(
          Failure(
              "Nessuna connessione ad internet, riprova appena sarai connesso."),
        );
      }

      final mediaUrl = await remoteDataSource.uploadMedia(
        leagueId: leagueId,
        mediaFile: mediaFile,
      );

      return Right(mediaUrl);
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
}
