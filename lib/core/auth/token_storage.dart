import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<void> save(String accessToken);
  Future<String?> get accessToken;
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  static const _accessKey = 'access_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> save(String accessToken) => _storage.write(key: _accessKey, value: accessToken);

  @override
  Future<String?> get accessToken => _storage.read(key: _accessKey);

  @override
  Future<void> clear() => _storage.delete(key: _accessKey);
}