import '../network/api_client.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}

class AuthService {
  final ApiClient api;

  AuthService(this.api);

  Future<AuthResult> loginWithGoogle(String idToken) async {
    final res = await api.dio.post(
      '/auth/google',
      data: {'idToken': idToken},
    );
    return AuthResult.fromJson(res.data);
  }

  Future<AuthResult> refresh(String refreshToken) async {
    final res = await api.dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return AuthResult.fromJson(res.data);
  }

  Future<void> logout() async {
    await api.dio.post('/auth/logout');
  }
}
