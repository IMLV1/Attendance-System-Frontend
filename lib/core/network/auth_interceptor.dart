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
  dio.interceptors.add(
    InterceptorsWrapper(
      /// Called before request is sent
      onRequest: (options, handler) async {
        final token = await tokenStorage.accessToken;

        // Attach Authorization header if token exists
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },

      /// Called when request returns an error
      onError: (e, handler) async {
        // If token is invalid or expired
        if (e.response?.statusCode == 401) {
          // Logout user and clear local auth data
          await authRepository.logout();
        }

        handler.next(e);
      },
    ),
  );
}
