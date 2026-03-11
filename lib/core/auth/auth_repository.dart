import 'package:attendance_system/core/auth/user_model.dart';

import '../network/api_client.dart';
import 'auth_api_service.dart';
import 'auth_result.dart';
import 'google_login_service.dart';
import 'token_storage.dart';

abstract class AuthRepository {
  Future<AuthResult> loginWithGoogle();
  Future<bool> hasToken();
  Future<void> logout();
  Future<void> forceLogout();
  Future<UserModel?> getUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService api;
  final TokenStorage storage;
  final GoogleLoginService google;
  final ApiClient apiClient;

  bool _isLoggingOut = false;

  AuthRepositoryImpl(
      this.api,
      this.storage,
      this.google,
      this.apiClient,
  );

  @override
  Future<AuthResult> loginWithGoogle() async {
    final googleToken = await google.login();

    if (googleToken == null) {
      throw Exception('Login cancelled');
    }

    final res = await api.loginWithGoogle(googleToken);

    if (res.accessToken.isEmpty) {
      throw Exception('Access token missing from backend');
    }

    // Save access token securely
    await storage.save(res.accessToken);

    // Attach token to API client for next requests
    apiClient.setToken(res.accessToken);

    return res;
  }

  @override
  Future<bool> hasToken() async {
    final token = await storage.accessToken;
    if (token == null) return false;

    apiClient.setToken(token);

    try {
      await api.getMe(); // ถ้า token หมดอายุ จะ throw
      return true;
    } catch (_) {
      await storage.clear();
      apiClient.clearToken();
      return false;
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      return await api.getMe();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      try {
        await api.logout(); // best effort
      } catch (_) {}

      await storage.clear();
      apiClient.clearToken();
      await google.logout();
    } finally {
      _isLoggingOut = false;
    }
  }

  @override
  Future<void> forceLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      await storage.clear();
      apiClient.clearToken();
      await google.logout();
    } finally {
      _isLoggingOut = false;
    }
  }
}