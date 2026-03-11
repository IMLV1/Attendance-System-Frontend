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
      baseUrl = 'http://mc-developcraft.net:3000';
    } else {
      if (kIsWeb) {
        baseUrl = 'http://mc-developcraft.net:3000'; // Web
      } else {
        baseUrl = 'http://mc-developcraft.net:3000'; // Android Emulator / iOS
      }
    }
  }
}
