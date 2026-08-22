import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleLoginService {
  Future<String?> login();
  Future<void> logout();

  /// 🚩 (2026-08-23) อีเมลของบัญชี Google ที่เพิ่งเลือกล่าสุด
  /// ใช้บอกผู้ใช้ตอน login ไม่ผ่านว่าเลือกบัญชีไหนไป — เคสที่เจอบ่อยคือ
  /// Google เลือกบัญชีส่วนตัวให้อัตโนมัติ ทั้งที่ระบบรู้จักแค่บัญชีที่ HR ลงทะเบียนไว้
  String? get lastEmail;
}

class GoogleLoginServiceImpl implements GoogleLoginService {
  late final GoogleSignIn _googleSignIn;

  String? _lastEmail;

  @override
  String? get lastEmail => _lastEmail;

  GoogleLoginServiceImpl() {
    _googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile', 'openid'],
      clientId: kIsWeb ? dotenv.env['GOOGLE_CLIENT_ID_WEB'] : null,
    );
  }

  @override
  Future<String?> login() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      _lastEmail = account.email;

      final auth = await account.authentication;

      debugPrint('idToken = ${auth.idToken}');
      debugPrint('accessToken = ${auth.accessToken}');

      if (auth.accessToken == null) {
        throw Exception('Access token not found');
      }

      return auth.accessToken;
    } catch (e, s) {
      debugPrint('Google Sign-In error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // Ignore disconnect error
    }
    await _googleSignIn.signOut();
  }
}