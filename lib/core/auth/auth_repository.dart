import '../network/api_client.dart';
import 'auth_api_service.dart';
import 'google_login_service.dart';
import 'token_storage.dart';

abstract class AuthRepository {
  Future<void> loginWithGoogle();
  Future<bool> refreshToken();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService api;
  final TokenStorage storage;
  final GoogleLoginService google;
  final ApiClient apiClient;

  AuthRepositoryImpl(
      this.api,
      this.storage,
      this.google,
      this.apiClient,
      );

  @override
  Future<void> loginWithGoogle() async {
    final idToken = await google.login();
    if (idToken == null) throw Exception('Login cancelled');

    final res = await api.loginWithGoogle(idToken);
    await storage.save(res.accessToken, res.refreshToken);
    apiClient.setToken(res.accessToken);
  }

  @override
  Future<bool> refreshToken() async {
    final refresh = await storage.refreshToken;
    if (refresh == null) return false;

    try {
      final res = await api.refresh(refresh);
      await storage.save(res.accessToken, res.refreshToken);
      apiClient.setToken(res.accessToken);
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await api.logout();
    await storage.clear();
    apiClient.clearToken();
    await google.logout();
  }
}
