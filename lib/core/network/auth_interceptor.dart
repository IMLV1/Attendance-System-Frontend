import 'package:dio/dio.dart';
import '../auth/auth_repository.dart';
import '../auth/token_storage.dart';

void setupAuthInterceptor(
    Dio dio, {
      required AuthRepository authRepository,
      required TokenStorage tokenStorage,
    }) {
  bool isRefreshing = false;

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
        if (e.response?.statusCode == 401 &&
            !e.requestOptions.path.contains('/auth/refresh')) {

          if (isRefreshing) {
            return handler.next(e);
          }

          isRefreshing = true;
          final ok = await authRepository.refreshToken();
          isRefreshing = false;

          if (ok) {
            final newToken = await tokenStorage.accessToken;
            if (newToken != null) {
              e.requestOptions.headers['Authorization'] =
              'Bearer $newToken';

              try {
                final retry = await dio.fetch(e.requestOptions);
                return handler.resolve(retry);
              } catch (error) {
                if (error is DioException) {
                  return handler.reject(error);
                }
              }
            }
          }
        }
        handler.next(e);
      },
    ),
  );
}
