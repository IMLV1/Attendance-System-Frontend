import 'package:attendance_system/core/auth/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'auth_result.dart';

class AuthApiService {
  final Dio dio;

  AuthApiService(this.dio);

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

  Future<void> logout() async {
    final res = await dio.post('/auth/logout');
    debugPrint('logout = ${res.data}');
  }

  Future<UserModel> getMe() async {
    final res = await dio.get('/api/init');
    debugPrint('getMe = ${res.data}');

    return UserModel.fromJson(res.data);
  }
}