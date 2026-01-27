import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
  ApiClient(this.dio);

  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    dio.options.headers.remove('Authorization');
  }
}
