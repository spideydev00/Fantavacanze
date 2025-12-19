class ServerException implements Exception {
  final String message;
  final dynamic data;

  ServerException(this.message, {this.data});

  @override
  String toString() {
    if (data == null) return 'ServerException: $message';
    return 'ServerException: $message | data: $data';
  }
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
