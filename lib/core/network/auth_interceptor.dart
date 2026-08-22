import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../auth/auth_repository.dart';
import '../auth/auth_state.dart';
import '../auth/token_storage.dart';

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

          // 🚩 แก้ (2026-08-22): เดิมเรียก authRepository.logout() ตรงๆ ซึ่งล้าง token ทิ้ง
          // แต่ไม่ได้อัปเดต AuthState เลย -> router ไม่รู้ว่าหลุด session แล้ว ไม่ redirect
          // ไปหน้า login ผู้ใช้ค้างอยู่หน้าเดิม แล้วทุก request ถัดไปไม่มี token ทำให้ขึ้น
          // "Authorization header is required" รัวๆ แทนที่จะเด้งไปให้ล็อกอินใหม่
          // (เกิดตอน token หมดอายุ 24 ชม. ระหว่างเปิดแอปค้างไว้)
          try {
            if (GetIt.I.isRegistered<AuthState>()) {
              await GetIt.I<AuthState>().logout(); // เรียก repo.logout() + notifyListeners ให้ด้วย
            } else {
              await authRepository.logout();
            }
          } catch (_) {
            await authRepository.logout(); // กันพลาด อย่างน้อยต้องล้าง token
          }

          isLoggingOut = false;
        }

        handler.next(e);
      },
    ),
  );
}
