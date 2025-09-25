import 'package:hive/hive.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/league/fs_league_model.dart';

abstract interface class FsLocalDataSource {
  Future<FsLeagueModel?> getCachedFsLeague();
  Future<void> cacheFsLeague(FsLeagueModel? league);
  Future<void> clearFsLeagueCache();
}

class FsLocalDataSourceImpl implements FsLocalDataSource {
  final Box<FsLeagueModel> fsLeaguesBox;

  const FsLocalDataSourceImpl(this.fsLeaguesBox);

  @override
  Future<FsLeagueModel?> getCachedFsLeague() async {
    try {
      final values = fsLeaguesBox.values.toList();
      return values.isNotEmpty ? values.first : null;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheFsLeague(FsLeagueModel? league) async {
    try {
      await fsLeaguesBox.clear();
      if (league != null) {
        await fsLeaguesBox.put(league.id, league);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearFsLeagueCache() async {
    try {
      await fsLeaguesBox.clear();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
