class ServerException implements Exception {
  final String message;
  final dynamic data;

  ServerException(this.message, {this.data});
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);
}
