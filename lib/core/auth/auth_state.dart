import 'package:flutter/foundation.dart';
import 'auth_repository.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState extends ChangeNotifier {
  final AuthRepository repo;

  AuthStatus status = AuthStatus.unknown;
  bool _refreshing = false;

  AuthState(this.repo);

  bool get isLoggedIn => status == AuthStatus.authenticated;

  Future<void> init() async {
    try {
      final ok = await repo.refreshToken();
      status = ok
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    try {
      await repo.loginWithGoogle();
      status = AuthStatus.authenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> refreshToken() async {
    if (_refreshing) return false;
    _refreshing = true;

    try {
      final ok = await repo.refreshToken();
      status = ok
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
      return ok;
    } finally {
      _refreshing = false;
    }
  }

  Future<void> logout() async {
    await repo.logout();
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
