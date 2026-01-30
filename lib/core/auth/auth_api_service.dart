import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'auth_result.dart';

/// Service class for authentication APIs
class AuthApiService {
  final Dio dio;

  /// Dio should be configured with baseUrl, interceptors, etc.
  AuthApiService(this.dio);

  /// Google access token from client
  /// Backend will verify it and return JWT + user info
  Future<AuthResult> loginWithGoogle(String accessToken) async {
    try {
      final res = await dio.post(
        '/auth/google',
        data: {
          'token': accessToken,
        },
      );

      debugPrint('login response = ${res.data}');

      return AuthResult.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint('login error = ${e.response?.data}');
      rethrow;
    }
  }

  /// Best-effort logout
  Future<void> logout() async {
    try {
      final res = await dio.post('/auth/logout');
      debugPrint('logout response = ${res.data}');
    } catch (_) {
      // ignore
    }
  }
}
