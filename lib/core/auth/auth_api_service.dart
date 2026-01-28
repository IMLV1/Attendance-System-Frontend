import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class AuthResult {
  final String accessToken;
  final String role;

  AuthResult({
    required this.accessToken,
    required this.role,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['accessToken'],
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
      data: {'token': accessToken},
    );

    debugPrint('res = ${res.data}');
    return AuthResult.fromJson(res.data);
  }

  Future<void> logout() async {
    await dio.post('/auth/logout');
  }
}
