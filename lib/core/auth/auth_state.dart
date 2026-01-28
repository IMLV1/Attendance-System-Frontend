import 'package:flutter/material.dart';

import 'auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends ChangeNotifier {
  final AuthRepository repo;

  AuthStatus status = AuthStatus.unknown;
  String? role;

  AuthState(this.repo);

  bool get isLoggedIn => status == AuthStatus.authenticated;

  Future<void> init() async {
    final ok = await repo.hasToken();
    status = ok ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    final result = await repo.loginWithGoogle();
    role = result.role;
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await repo.logout();
    role = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

