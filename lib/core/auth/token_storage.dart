import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStorage {
  Future<void> save(String access, String refresh);
  Future<void> clear();
  Future<String?> get accessToken;
  Future<String?> get refreshToken;
}

class MobileTokenStorage implements TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final _storage = const FlutterSecureStorage();

  @override
  Future<void> save(String access, String refresh) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  @override
  Future<String?> get accessToken =>
      _storage.read(key: _accessKey);

  @override
  Future<String?> get refreshToken =>
      _storage.read(key: _refreshKey);
}

/* ================= Web ================= */

class WebTokenStorage implements TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<void> save(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<String?> get accessToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  @override
  Future<String?> get refreshToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }
}

TokenStorage createTokenStorage() {
  if (kIsWeb) return WebTokenStorage();
  return MobileTokenStorage();
}
