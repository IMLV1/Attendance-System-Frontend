import '../network/api_client.dart';
import 'auth_api_service.dart';
import 'auth_result.dart';
import 'google_login_service.dart';
import 'token_storage.dart';

/// Authentication repository contract
abstract class AuthRepository {
  /// Login with Google and return auth result
  Future<AuthResult> loginWithGoogle();

  /// Check if access token exists in local storage
  Future<bool> hasToken();

  /// Logout user and clear all auth data
  Future<void> logout();
}

/// Authentication repository implementation
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

  /// Login flow:
  /// 1. Sign in with Google
  /// 2. Send Google token to backend
  /// 3. Receive JWT access token
  /// 4. Save token locally and attach to API client
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

  /// Check existing login state
  /// If token exists, attach it to API client
  @override
  Future<bool> hasToken() async {
    final token = await storage.accessToken;

    if (token != null) {
      apiClient.setToken(token);
      return true;
    }

    return false;
  }

  /// Logout flow:
  /// 1. Notify backend (best effort)
  /// 2. Clear local token storage
  /// 3. Remove token from API client
  /// 4. Logout from Google
  @override
  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      await api.logout();
      await storage.clear();
      apiClient.clearToken();
      await google.logout();
    } finally {
      _isLoggingOut = false;
    }
  }

}