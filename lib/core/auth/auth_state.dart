import 'package:flutter/material.dart';

import 'auth_repository.dart';

/// Authentication status
enum AuthStatus {
  unknown,          // Initial / checking auth state
  authenticated,    // User is logged in
  unauthenticated,  // User is logged out
}

/// Global authentication state
/// Used by GoRouter and UI to react to auth changes
class AuthState extends ChangeNotifier {
  final AuthRepository repo;

  /// Current authentication status
  AuthStatus status = AuthStatus.unknown;

  /// Current user role (e.g. admin, approval, user)
  String? role;

  AuthState(this.repo);

  /// Helper getter for login check
  bool get isLoggedIn => status == AuthStatus.authenticated;

  /// Initialize auth state on app start
  ///
  /// Checks if access token exists in local storage
  /// and updates authentication status
  Future<void> init() async {
    final ok = await repo.hasToken();
    status = ok ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Login with Google
  /// Delegates login logic to repository
  /// and updates auth state and role
  Future<void> loginWithGoogle() async {
    try {
      final result = await repo.loginWithGoogle();
      role = result.role;
      status = AuthStatus.authenticated;
    } catch (e) {
      status = AuthStatus.unauthenticated;
      rethrow;
    } finally {
      notifyListeners();
    }
  }


  /// Logout user
  /// Clears tokens, resets role, and updates auth state
  Future<void> logout() async {
    await repo.logout();
    role = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
