import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class GoogleLoginService {
  Future<String?> login();
  Future<void> logout();
}

class GoogleLoginServiceImpl implements GoogleLoginService {
  late final GoogleSignIn _googleSignIn;

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

      final auth = await account.authentication;

      debugPrint('📱 accessToken = ${auth.accessToken}');
      debugPrint('📱 idToken = ${auth.idToken}');

      if (auth.accessToken == null) {
        throw Exception('ไม่พบ accessToken');
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
    await _googleSignIn.signOut();
  }
}
