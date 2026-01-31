import 'package:attendance_system/core/auth/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'auth_result.dart';

/// Auth result model from backend
/// Contains access token and user role

/// Service class for authentication APIs
class AuthApiService {
  final Dio dio;

  /// Dio should be configured with baseUrl, interceptors, etc.
  AuthApiService(this.dio);

  /// accessToken is the Google access token from client
  /// Backend will verify it and return JWT + role
  Future<AuthResult> loginWithGoogle(String accessToken) async {
    final res = await dio.post(
      '/auth/google',
      data: {
        'token': accessToken, // Google token
      },
    );

    // Debug backend response
    debugPrint('login = ${res.data}');

    return AuthResult.fromJson(res.data);
  }

  /// Usually used to invalidate refresh token on backend
  /// Client still needs to clear local token storage
  Future<void> logout() async {
    final res = await dio.post('/auth/logout');
    debugPrint('logout = ${res.data}');
  }

  Future<UserModel> getMe() async {
    final res = await dio.get('/auth/me');
    return UserModel.fromJson(res.data);
  }
}