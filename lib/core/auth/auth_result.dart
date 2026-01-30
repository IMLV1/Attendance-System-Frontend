import 'package:attendance_system/core/auth/user_model.dart';

class AuthResult {
  final String accessToken;
  final User user;
  final String? picture;

  AuthResult({
    required this.accessToken,
    required this.user,
    this.picture,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['access_token'],
      user: User.fromJson(json['user']),
      picture: json['picture'],
    );
  }
}
