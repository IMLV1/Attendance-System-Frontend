import 'package:dio/dio.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final String role;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      role: json['role'],
    );
  }
}

class AuthApiService {
  final Dio dio;
  AuthApiService(this.dio);

  Future<AuthResult> loginWithGoogle(String accessToken) async {
    final res = await dio.post(
      '/auth/google',
      data: {'accessToken': accessToken},
    );
    return AuthResult.fromJson(res.data);
  }

  Future<AuthResult> refresh(String refreshToken) async {
    final res = await dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return AuthResult.fromJson(res.data);
  }

  Future<void> logout() async {
    await dio.post('/auth/logout');
  }
}
