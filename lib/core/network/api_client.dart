import 'package:dio/dio.dart';

/// API client wrapper for Dio
/// Handles global request configuration such as auth token
class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  /// Attach access token to Authorization header
  /// Format: Authorization: Bearer <token>
  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove Authorization header
  /// Used when user logs out
  void clearToken() {
    dio.options.headers.remove('Authorization');
  }
}
