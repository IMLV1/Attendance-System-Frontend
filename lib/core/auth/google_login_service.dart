import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class GoogleLoginService {
  Future<String?> login();
  Future<void> logout();
}

class GoogleLoginServiceImpl implements GoogleLoginService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    clientId: kIsWeb ? dotenv.env['GOOGLE_CLIENT_ID_WEB'] : null,
  );

  @override
  Future<String?> login() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;

    return kIsWeb ? auth.accessToken : auth.idToken;
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
  }
}

