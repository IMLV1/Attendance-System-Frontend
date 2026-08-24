import 'package:attendance_system/core/auth/user_model.dart';

class AuthResult {
  final String accessToken;

  // 🚩 (2026-08-22) refresh token ใช้ต่ออายุ access token เงียบๆ
  // บนเว็บ backend ส่งเป็น httpOnly cookie ด้วย ค่าตรงนี้อาจว่างได้
  final String? refreshToken;

  final UserModel user;

  AuthResult({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

