import 'package:go_router/go_router.dart';
import '../core/auth/auth_state.dart';
import '../features/auth/login_page.dart';
import '../service_locator.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (_, state) {
    final auth = getIt<AuthState>();
    final isLogin = state.uri.toString() == '/login';

    if (!auth.isLoggedIn && !isLogin) return '/login';
    if (auth.isLoggedIn && isLogin) return '/home';

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
  ],
);
