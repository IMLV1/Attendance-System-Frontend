import 'package:dio/dio.dart';

import '../auth/auth_repository.dart';
import '../auth/token_storage.dart';

void setupAuthInterceptor(
    Dio dio, {
      required AuthRepository authRepository,
      required TokenStorage tokenStorage,
    }) {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          await authRepository.logout();
        }
        handler.next(e);
      },
    ),
  );
}
