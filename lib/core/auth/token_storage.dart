import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  /// 🚩 (2026-08-22) เก็บทั้ง access + refresh token
  /// access อายุสั้น (15 นาที) / refresh อายุยาว ใช้ต่ออายุ access เงียบๆ
  /// บนเว็บ refresh token ถูกเก็บเป็น httpOnly cookie ฝั่ง server ด้วย (JS อ่านไม่ได้)
  /// ตัวที่เก็บตรงนี้จึงเป็น fallback สำหรับแอปเป็นหลัก
  Future<void> save(String accessToken, {String? refreshToken});
  Future<String?> get accessToken;
  Future<String?> get refreshToken;
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> save(String accessToken, {String? refreshToken}) async {
    await _storage.write(key: _accessKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  @override
  Future<String?> get accessToken => _storage.read(key: _accessKey);

  @override
  Future<String?> get refreshToken => _storage.read(key: _refreshKey);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
