import 'package:attendance_system/services/profile_service/profile_service.dart';
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

/// Global service locator instance
final getIt = GetIt.instance;

/// Setup dependency injection
///
/// Registers:
/// - Network (Dio, ApiClient)
/// - Auth services (Google login, token storage, API)
/// - Auth state & repository
/// - Dio auth interceptor
Future<void> setupServiceLocator() async {
  /// Initialize API configuration (baseUrl, headers, timeouts)
  ApiConfig.init();

  /// Create Dio instance with base configuration
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: ApiConfig.defaultHeaders,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ),
  );

  /// Register Dio (single instance)
  getIt.registerSingleton<Dio>(dio);

  /// Register API client wrapper
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(dio));

  /// Google Sign-In service
  getIt.registerLazySingleton<GoogleLoginService>(
        () => GoogleLoginServiceImpl(),
  );

  /// Secure token storage
  getIt.registerLazySingleton<TokenStorage>(
        () => SecureTokenStorage(),
  );

  /// Auth API service (network only)
  getIt.registerLazySingleton<AuthApiService>(
        () => AuthApiService(dio),
  );

  /// Auth repository (business logic)
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      getIt(), // AuthApiService
      getIt(), // TokenStorage
      getIt(), // GoogleLoginService
      getIt(), // ApiClient
    ),
  );

  /// Global authentication state
  getIt.registerLazySingleton<AuthState>(
        () => AuthState(getIt()),
  );

  /// Setup Dio auth interceptor
  /// - Attach access token to requests
  /// - Auto logout on 401 response
  setupAuthInterceptor(
    dio,
    authRepository: getIt<AuthRepository>(),
    tokenStorage: getIt<TokenStorage>(),
  );

  getIt.registerLazySingleton<ProfileService>(
        () => ProfileService()
  );

}
