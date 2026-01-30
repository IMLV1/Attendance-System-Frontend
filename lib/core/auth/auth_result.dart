import 'user.dart';

class AuthResult {
  final String accessToken;
  final User user;
  final String? pictureUrl;

  AuthResult({
    required this.accessToken,
    required this.user,
    this.pictureUrl,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['access_token'],
      user: User.fromJson(json['user']),
      pictureUrl: json['picture'],
    );
  }
}
