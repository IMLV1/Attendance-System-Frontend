import 'package:flutter/foundation.dart';

class ApiConfig {
  static late String baseUrl;

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 10);

  static const defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static void init() {
    const isProd = bool.fromEnvironment('dart.vm.product');

    if (isProd) {
      baseUrl = 'http://20.194.9.179:3000';
    } else {
      if (kIsWeb) {
        baseUrl = 'http://localhost:8080'; // Web
      } else {
        baseUrl = 'http://10.0.2.2:8080'; // Android Emulator / iOS
      }
    }
  }
}
