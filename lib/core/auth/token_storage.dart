import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token storage contract
/// Used to save, read, and clear access token
abstract class TokenStorage {
  /// Save access token securely
  Future<void> save(String accessToken);

  /// Get stored access token
  Future<String?> get accessToken;

  /// Clear stored access token
  Future<void> clear();
}

/// Secure implementation using FlutterSecureStorage
/// - Android: Keystore
/// - iOS: Keychain
class SecureTokenStorage implements TokenStorage {
  static const _accessKey = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Save access token to secure storage
  @override
  Future<void> save(String accessToken) =>
      _storage.write(key: _accessKey, value: accessToken);

  /// Read access token from secure storage
  @override
  Future<String?> get accessToken =>
      _storage.read(key: _accessKey);

  /// Remove access token from secure storage
  @override
  Future<void> clear() =>
      _storage.delete(key: _accessKey);
}
