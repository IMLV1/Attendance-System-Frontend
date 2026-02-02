import 'package:attendance_system/services/profile_page/profile_service.dart';
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

// --- ADD THIS IMPORT ---
// Update the path to match where your ProfileService file is located

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  /// API config
  ApiConfig.init();

  /// Dio (single instance)
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: ApiConfig.defaultHeaders,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ),
  );
  getIt.registerSingleton<Dio>(dio);

  /// Token storage
  getIt.registerLazySingleton<TokenStorage>(
        () => SecureTokenStorage(),
  );

  /// ApiClient
  getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(dio),
  );

  /// Google login
  getIt.registerLazySingleton<GoogleLoginService>(
        () => GoogleLoginServiceImpl(),
  );

  /// Auth API
  getIt.registerLazySingleton<AuthApiService>(
        () => AuthApiService(dio),
  );

  /// Profile Service
  getIt.registerLazySingleton<ProfileService>(
        () => ProfileService(),
  );

  /// Auth repository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      getIt<AuthApiService>(),
      getIt<TokenStorage>(),
      getIt<GoogleLoginService>(),
      getIt<ApiClient>(),
    ),
  );

  /// Dio auth interceptor
  setupAuthInterceptor(
    dio,
    authRepository: getIt<AuthRepository>(),
    tokenStorage: getIt<TokenStorage>(),
  );

  /// Global AuthState
  getIt.registerLazySingleton<AuthState>(
        () => AuthState(getIt<AuthRepository>()),
  );
}