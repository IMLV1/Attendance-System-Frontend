import 'auth_api_service.dart';
import 'google_login_service.dart';
import 'token_storage.dart';
import '../network/api_client.dart';

abstract class AuthRepository {
  Future<AuthResult> loginWithGoogle();
  Future<bool> hasToken();
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
  Future<AuthResult> loginWithGoogle() async {
    final googleToken = await google.login();
    if (googleToken == null) {
      throw Exception('Login cancelled');
    }

    final res = await api.loginWithGoogle(googleToken);

    await storage.save(res.accessToken);
    apiClient.setToken(res.accessToken);

    return res;
  }


  @override
  Future<bool> hasToken() async {
    final token = await storage.accessToken;
    if (token != null) {
      apiClient.setToken(token);
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    try {
      await api.logout();
    } catch (_) {}
    await storage.clear();
    apiClient.clearToken();
    await google.logout();
  }
}
