import 'package:attendance_system/core/auth/user_model.dart';
import 'package:flutter/material.dart';

import 'auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends ChangeNotifier {
  final AuthRepository repo;

  AuthStatus status = AuthStatus.unknown;

  UserModel? user;

  AuthState(this.repo);

  bool get isLoggedIn => status == AuthStatus.authenticated;

  Future<void> init() async {
    final ok = await repo.hasToken();
    status = ok ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    try {
      final result = await repo.loginWithGoogle();
      user = result.user;
      status = AuthStatus.authenticated;
    } catch (e) {
      status = AuthStatus.unauthenticated;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repo.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}