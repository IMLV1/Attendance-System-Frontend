import 'package:attendance_system/core/data/api/check_in_api.dart';
import 'package:attendance_system/core/data/api/config_attendance_time_api.dart';
import 'package:attendance_system/core/data/api/holiday_api.dart';
import 'package:attendance_system/core/data/api/profile_api.dart';
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

  getIt.registerLazySingleton<TokenStorage>(
        () => SecureTokenStorage(),
  );

  getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(dio),
  );

  getIt.registerLazySingleton<GoogleLoginService>(
        () => GoogleLoginServiceImpl(),
  );

  getIt.registerLazySingleton<AuthApiService>(
        () => AuthApiService(dio),
  );

  getIt.registerLazySingleton<ProfileService>(
        () => ProfileService(),
  );

  getIt.registerLazySingleton<AttendanceService>(
        () => AttendanceService(),
  );

  getIt.registerLazySingleton<HolidayService>(() => HolidayService(getIt<Dio>()));

  // ในไฟล์ setup ของคุณ
  getIt.registerLazySingleton<ConfigAttendanceTimeService>(() => ConfigAttendanceTimeService());

  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      getIt<AuthApiService>(),
      getIt<TokenStorage>(),
      getIt<GoogleLoginService>(),
      getIt<ApiClient>(),
    ),
  );

  setupAuthInterceptor(
    dio,
    authRepository: getIt<AuthRepository>(),
    tokenStorage: getIt<TokenStorage>(),
  );


  getIt.registerLazySingleton<AuthState>(
        () => AuthState(getIt<AuthRepository>()),
  );
}
