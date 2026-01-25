import 'package:attendance_system/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/auth/login_page.dart';
import '../service_locator.dart';

final appRouter = GoRouter(
  refreshListenable: getIt<AuthState>(),
  initialLocation: '/splash',
  redirect: (_, state) {
    final auth = getIt<AuthState>();
    final location = state.matchedLocation;

    if (auth.status == AuthStatus.unknown) {
      return location == '/splash' ? null : '/splash';
    }

    final isLogin = location == '/login';
    final isSplash = location == '/splash';

    if (!auth.isLoggedIn) {
      return isLogin ? null : '/login';
    }

    if (auth.isLoggedIn && (isLogin || isSplash)) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: LoginPage(),
      )
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const Scaffold(
        body: Center(child: Text('HOME')),
      ),
    ),
  ],
);
