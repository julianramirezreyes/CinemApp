class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server Exception']);
}

class CacheException implements Exception {}

class DatabaseException implements Exception {
  final String message;
  DatabaseException([this.message = 'Database Exception']);
}
