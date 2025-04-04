class ServerException implements Exception {
  final String message;
  final dynamic data;

  const ServerException(this.message, {this.data});

  @override
  String toString() => 'ServerException: $message';
}
