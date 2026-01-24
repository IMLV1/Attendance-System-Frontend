import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'core/auth/token_storage.dart';
import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/network/auth_interceptor.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: ApiConfig.defaultHeaders,
    ),
  );

  setupAuthInterceptor(dio);

  getIt.registerSingleton<Dio>(dio);
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt()));
  getIt.registerLazySingleton<TokenStorage>(() => createTokenStorage());
}
