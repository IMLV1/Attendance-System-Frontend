import 'package:dio/dio.dart';
import '../../../service_locator.dart';
import '../auth/auth_state.dart';

void setupAuthInterceptor(Dio dio) {
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final auth = getIt<AuthState>();
          final ok = await auth.refreshToken();
          if (ok) {
            final retry = await dio.fetch(e.requestOptions);
            return handler.resolve(retry);
          }
        }
        handler.next(e);
      },
    ),
  );
}
