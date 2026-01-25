import 'package:dio/dio.dart';

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

class AuthApiService {
  final Dio dio;

  AuthApiService(this.dio);

  Future<AuthResult> loginWithGoogle(String googleToken) async {
    final res = await dio.post(
      '/auth/google',
      data: {
        'token': googleToken,
      },
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

