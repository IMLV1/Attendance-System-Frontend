import '../core/auth/auth_service.dart';
import '../core/auth/auth_state.dart';
import '../service_locator.dart';

Future<void> setupAppDI() async {
  getIt.registerLazySingleton<AuthService>(
        () => AuthService(getIt()),
  );

  getIt.registerLazySingleton<AuthState>(
        () => AuthState(
      getIt<AuthService>(),
      getIt(),
      getIt(),
    ),
  );
}
