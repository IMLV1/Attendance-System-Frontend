import 'package:dio/dio.dart';

import '../auth/auth_repository.dart';
import '../auth/token_storage.dart';

/// Setup authentication interceptor for Dio
///
/// - Automatically attaches access token to every request
/// - Handles 401 Unauthorized responses by logging out user
void setupAuthInterceptor(
    Dio dio, {
      required AuthRepository authRepository,
      required TokenStorage tokenStorage,
    }) {
  bool isLoggingOut = false;

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
        final status = e.response?.statusCode;
        final path = e.requestOptions.path;

        if (status == 401 &&
            !isLoggingOut &&
            !path.contains('/auth/google') &&
            !path.contains('/auth/logout')) {

          isLoggingOut = true;
          await authRepository.logout();
          isLoggingOut = false;
        }

        handler.next(e);
      },
    ),
  );
}

