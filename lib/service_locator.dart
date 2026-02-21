import 'package:attendance_system/core/data/api/check_in_api.dart';
import 'package:attendance_system/core/data/api/config_attendance_time_api.dart';
import 'package:attendance_system/core/data/api/holiday_api.dart';
import 'package:attendance_system/core/data/api/profile_api.dart';
import 'package:attendance_system/core/data/provider/profile_provider.dart';
import 'package:attendance_system/core/data/repositories/profile_repository.dart';
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

final sl = GetIt.instance;

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

  sl..registerSingleton<Dio>(dio)
    ..registerLazySingleton<TokenStorage>(() => SecureTokenStorage())
    ..registerLazySingleton<ApiClient>(() => ApiClient(dio))
    ..registerLazySingleton<GoogleLoginService>(() => GoogleLoginServiceImpl())
    ..registerLazySingleton<AuthApiService>(() => AuthApiService(dio))

    ..registerLazySingleton<ProfileApi>(() => ProfileApi())
    ..registerLazySingleton<ProfileRepository>(() => ProfileRepository())
    ..registerLazySingleton<ProfileProvider>(() => ProfileProvider(sl<AuthState>(), sl<ProfileRepository>()))

    ..registerLazySingleton<AttendanceApi>(() => AttendanceApi())
    ..registerLazySingleton<HolidayApi>(() => HolidayApi())
    ..registerLazySingleton<ConfigAttendanceTimeApi>(() => ConfigAttendanceTimeApi())

    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        sl<AuthApiService>(),
        sl<TokenStorage>(),
        sl<GoogleLoginService>(),
        sl<ApiClient>(),
      ),
    )
    ..registerLazySingleton<AuthState>(() => AuthState(sl<AuthRepository>()));

  setupAuthInterceptor(
    dio,
    authRepository: sl<AuthRepository>(),
    tokenStorage: sl<TokenStorage>(),
  );
}
