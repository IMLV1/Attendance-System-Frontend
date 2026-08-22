import 'package:attendance_system/core/auth/user_model.dart';
import 'package:dio/dio.dart';

import '../network/api_client.dart';
import 'auth_api_service.dart';
import 'auth_result.dart';
import 'google_login_service.dart';
import 'token_storage.dart';

/// ผู้ใช้กดปิดหน้าเลือกบัญชี Google เอง — ไม่ใช่ error ไม่ต้องขึ้นข้อความแดง
class LoginCancelled implements Exception {
  const LoginCancelled();
}

/// 🚩 (2026-08-23) login ไม่สำเร็จ พร้อมข้อมูลพอที่จะบอกผู้ใช้ได้ว่า "เพราะอะไร"
///
/// เดิม error ทุกแบบถูกกลืนเป็นข้อความเดียวกันหมดที่ [AuthState.loginWithGoogle]
/// ("ไม่สามารถเข้าสู่ระบบได้ กรุณาติดต่อนักทรัพยากรบุคคล") ไม่ว่าจะเป็นต่อ
/// เซิร์ฟเวอร์ไม่ติด, token Google ใช้ไม่ได้ หรือบัญชีไม่มีในระบบ
/// -> ทั้งผู้ใช้และคนดูแลระบบแยกไม่ออกว่าต้องไปแก้ตรงไหน
class LoginFailure implements Exception {
  /// HTTP status จาก backend (null = ต่อไม่ถึง / ไม่มี response)
  final int? statusCode;

  /// ข้อความดิบจาก field "error" ของ backend
  final String? backendError;

  /// อีเมล Google ที่ใช้ล็อกอิน — ช่วยให้ผู้ใช้รู้ว่าเผลอเลือกบัญชีผิดรึเปล่า
  final String? email;

  final DioExceptionType? type;

  const LoginFailure({
    this.statusCode,
    this.backendError,
    this.email,
    this.type,
  });

  @override
  String toString() =>
      'LoginFailure(status: $statusCode, backend: $backendError, email: $email, type: $type)';
}

abstract class AuthRepository {
  Future<AuthResult> loginWithGoogle();
  Future<bool> hasToken();
  Future<void> logout();
  Future<void> forceLogout();
  Future<UserModel?> getUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService api;
  final TokenStorage storage;
  final GoogleLoginService google;
  final ApiClient apiClient;

  bool _isLoggingOut = false;

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
      throw const LoginCancelled();
    }

    AuthResult res;
    try {
      res = await api.loginWithGoogle(googleToken);
    } on DioException catch (e) {
      final data = e.response?.data;
      throw LoginFailure(
        statusCode: e.response?.statusCode,
        backendError:
            (data is Map && data['error'] != null) ? data['error'].toString() : null,
        email: google.lastEmail,
        type: e.type,
      );
    }

    if (res.accessToken.isEmpty) {
      throw LoginFailure(
        backendError: 'Access token missing from backend',
        email: google.lastEmail,
      );
    }

    // Save access token securely
    await storage.save(res.accessToken, refreshToken: res.refreshToken);

    // Attach token to API client for next requests
    apiClient.setToken(res.accessToken);

    return res;
  }

  @override
  Future<bool> hasToken() async {
    final token = await storage.accessToken;
    if (token == null) return false;

    apiClient.setToken(token);

    try {
      await api.getMe(); // ถ้า token หมดอายุ จะ throw
      return true;
    } catch (_) {
      await storage.clear();
      apiClient.clearToken();
      return false;
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      return await api.getMe();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      try {
        await api.logout(await storage.refreshToken); // best effort — เพิกถอน refresh token ฝั่ง server
      } catch (_) {}

      await storage.clear();
      apiClient.clearToken();
      await google.logout();
    } finally {
      _isLoggingOut = false;
    }
  }

  @override
  Future<void> forceLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      await storage.clear();
      apiClient.clearToken();
      await google.logout();
    } finally {
      _isLoggingOut = false;
    }
  }
}