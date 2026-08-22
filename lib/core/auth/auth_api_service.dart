import 'package:attendance_system/core/auth/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'auth_result.dart';

class TokenPair {
  final String accessToken;
  final String? refreshToken;
  const TokenPair({required this.accessToken, this.refreshToken});
}

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

  Future<void> logout([String? refreshToken]) async {
    // ส่ง refresh token ไปให้ server เพิกถอนจริง (เว็บใช้ cookie อัตโนมัติ)
    final res = await dio.post(
      '/auth/logout',
      data: refreshToken != null ? {'refresh_token': refreshToken} : null,
    );
    debugPrint('logout = ${res.data}');
  }

  /// ต่ออายุ access token ด้วย refresh token
  ///
  /// ใช้ Dio ตัวใหม่ที่ไม่มี interceptor โดยเจตนา — ถ้าใช้ตัวเดิมแล้ว /auth/refresh
  /// เองได้ 401 interceptor จะวนไปเรียก refresh ซ้ำไม่จบ
  Future<TokenPair> refresh(
    String? refreshToken, {
    required String baseUrl,
    required Map<String, dynamic> headers,
  }) async {
    final plain = Dio(BaseOptions(baseUrl: baseUrl, headers: headers));
    final res = await plain.post(
      '/auth/refresh',
      data: refreshToken != null ? {'refresh_token': refreshToken} : null,
    );
    final data = res.data as Map<String, dynamic>;
    return TokenPair(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String?,
    );
  }

  Future<UserModel> getMe() async {
    final res = await dio.get('/api/init');
    debugPrint('getMe = ${res.data}');

    return UserModel.fromJson(res.data);
  }
}