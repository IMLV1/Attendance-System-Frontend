import 'package:attendance_system/core/auth/user_model.dart';

class AuthResult {
  final String accessToken;
  final UserModel user;

  AuthResult({
    required this.accessToken,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['accessToken'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

