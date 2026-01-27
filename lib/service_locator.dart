import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'core/auth/auth_api_service.dart';
import 'core/auth/auth_repository.dart';
import 'core/auth/auth_state.dart';
import 'core/auth/google_login_service.dart';
import 'core/auth/token_storage.dart';
import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/network/auth_interceptor.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  ApiConfig.init();

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: ApiConfig.defaultHeaders,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ),
  );

  getIt.registerSingleton<Dio>(dio);
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(dio));

  getIt.registerLazySingleton<GoogleLoginService>(
        () => GoogleLoginServiceImpl(),
  );

  getIt.registerLazySingleton<TokenStorage>(
        () => SecureTokenStorage(),
  );

  getIt.registerLazySingleton<AuthApiService>(
        () => AuthApiService(dio),
  );

  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );

  getIt.registerLazySingleton<AuthState>(
        () => AuthState(getIt()),
  );

  setupAuthInterceptor(
    dio,
    authRepository: getIt<AuthRepository>(),
    tokenStorage: getIt<TokenStorage>(),
  );
}
