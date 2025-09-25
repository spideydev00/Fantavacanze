import 'package:hive/hive.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/league/fs_league_model.dart';

abstract interface class FsLocalDataSource {
  Future<List<FsLeagueModel>> getCachedFsLeagues();
  Future<void> cacheFsLeagues(List<FsLeagueModel> leagues);
  Future<void> clearFsLeaguesCache();
}

class FsLocalDataSourceImpl implements FsLocalDataSource {
  final Box<FsLeagueModel> fsLeaguesBox;

  const FsLocalDataSourceImpl(this.fsLeaguesBox);

  @override
  Future<List<FsLeagueModel>> getCachedFsLeagues() async {
    try {
      return fsLeaguesBox.values.toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheFsLeagues(List<FsLeagueModel> leagues) async {
    try {
      await fsLeaguesBox.clear();
      for (int i = 0; i < leagues.length; i++) {
        await fsLeaguesBox.put(leagues[i].id, leagues[i]);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearFsLeaguesCache() async {
    try {
      await fsLeaguesBox.clear();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
