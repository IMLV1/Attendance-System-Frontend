import 'package:attendance_system/core/auth/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google login service contract
abstract class GoogleLoginService {
  /// Sign in with Google and return access token
  Future<String?> login();

  /// Logout from Google
  Future<void> logout();
}

/// Google login service implementation
class GoogleLoginServiceImpl implements GoogleLoginService {
  late final GoogleSignIn _googleSignIn;

  /// Initialize GoogleSignIn
  /// - Uses web client ID when running on web
  /// - Requests basic profile scopes
  GoogleLoginServiceImpl() {
    _googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile', 'openid'],
      clientId: kIsWeb ? dotenv.env['GOOGLE_CLIENT_ID_WEB'] : null,
    );
  }

  /// Login with Google
  /// Returns Google access token if success
  /// Returns null if user cancels login
  @override
  Future<String?> login() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;

      // Debug tokens
      debugPrint('idToken = ${auth.idToken}');
      debugPrint('accessToken = ${auth.accessToken}');

      if (auth.accessToken == null) {
        throw Exception('Access token not found');
      }

      if (auth.idToken == null) {
        throw Exception('ID token not found');
      }

      // Return Google access token to backend
      return auth.accessToken;
    } catch (e, s) {
      debugPrint('Google Sign-In error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  /// Logout from Google account
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
