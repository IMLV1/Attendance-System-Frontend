import 'package:flutter/foundation.dart';

class ApiConfig {
  static late String baseUrl;

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 10);

  // 🚩 (2026-08-22) บอก backend ว่ามาจากเว็บหรือแอป — ใช้ตั้งอายุ refresh token
  // (เว็บ 14 วัน / มือถือ 90 วัน เพราะเว็บเสี่ยง XSS มากกว่า) และตัดสินใจว่าจะ
  // ส่ง refresh token เป็น httpOnly cookie มั้ย รวมถึงโชว์ในหน้า "อุปกรณ์ที่ลงชื่อเข้าใช้"
  static Map<String, dynamic> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
  };

  static void init() {
    const isProd = bool.fromEnvironment('dart.vm.product');

    if (isProd) {
      baseUrl = 'http://eng.src.ku.ac.th:3000';
    } else {
      if (kIsWeb) {
        baseUrl = 'http://localhost:3000'; // Web
      } else {
        baseUrl = 'http://localhost:3000'; // iOS Simulator (local backend)
        // Android Emulator: use http://10.0.2.2:3000 instead
      }
    }
  }
}
