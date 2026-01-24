import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'token_storage.dart';
import '../network/api_client.dart';

class AuthState extends ChangeNotifier {
  final AuthService authService;
  final ApiClient apiClient;
  final TokenStorage storage;

  bool isLoggedIn = false;
  bool _refreshing = false;

  AuthState(this.authService, this.apiClient, this.storage);

  /* ===== Restore on app start ===== */
  Future<void> init() async {
    final token = await storage.accessToken;
    if (token != null) {
      apiClient.setToken(token);
      isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> login(String idToken) async {
    final result = await authService.loginWithGoogle(idToken);
    await storage.save(result.accessToken, result.refreshToken);
    apiClient.setToken(result.accessToken);
    isLoggedIn = true;
    notifyListeners();
  }

  Future<bool> refreshToken() async {
    if (_refreshing) return false;

    final refresh = await storage.refreshToken;
    if (refresh == null) return false;

    _refreshing = true;
    try {
      final result = await authService.refresh(refresh);
      await storage.save(result.accessToken, result.refreshToken);
      apiClient.setToken(result.accessToken);
      return true;
    } catch (_) {
      await logout();
      return false;
    } finally {
      _refreshing = false;
    }
  }

  Future<void> logout() async {
    await authService.logout();
    await storage.clear();
    apiClient.clearToken();
    isLoggedIn = false;
    notifyListeners();
  }
}
