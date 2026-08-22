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

  /// 🚩 (2026-08-23) เปิดทาง override base URL ตอนสั่ง run ได้
  ///
  ///     flutter run --dart-define=API_BASE_URL=http://192.168.1.125:3000
  ///
  /// จำเป็นตอนรันบน **เครื่องจริง** (iPad / มือถือ) เพราะ `localhost` ของเครื่องจริง
  /// หมายถึงตัวเครื่องเอง ไม่ใช่ Mac ที่รัน backend อยู่ -> ต่อไม่ติด
  /// (SocketException: Connection refused, errno 61)
  ///
  /// simulator/emulator ไม่ต้องใส่ เพราะใช้ network stack ร่วมกับเครื่อง Mac อยู่แล้ว
  ///
  /// ใช้ dart-define แทน hardcode IP ลงซอร์ส เพราะ IP ของแต่ละเครื่อง/แต่ละ Wi-Fi
  /// ไม่เหมือนกัน ถ้า hardcode ไว้คนอื่นในทีมจะ run ไม่ได้
  static const _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static void init() {
    const isProd = bool.fromEnvironment('dart.vm.product');

    if (_envBaseUrl.isNotEmpty) {
      baseUrl = _envBaseUrl;
      return;
    }

    if (isProd) {
      baseUrl = 'http://eng.src.ku.ac.th:3000';
    } else {
      if (kIsWeb) {
        baseUrl = 'http://localhost:3000'; // Web
      } else {
        // iOS Simulator / Android Emulator ที่รัน backend บนเครื่องเดียวกัน
        // ⚠️ เครื่องจริงใช้ค่านี้ไม่ได้ ต้องส่ง --dart-define=API_BASE_URL=... ตามด้านบน
        baseUrl = 'http://localhost:3000';
        // Android Emulator: use http://10.0.2.2:3000 instead
      }
    }
  }
}
