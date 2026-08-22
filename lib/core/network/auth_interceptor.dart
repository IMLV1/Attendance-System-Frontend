import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../auth/auth_api_service.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_state.dart';
import '../auth/token_storage.dart';
import 'api_config.dart';

/// 🚩 (2026-08-22) เปลี่ยนจาก "401 = เตะออกทันที" เป็น "401 = ลองต่ออายุก่อน"
///
/// access token อายุแค่ 15 นาที ถ้าเจอ 401 แล้วเตะออกเลย ผู้ใช้จะโดนเตะทุก 15 นาที
/// flow ใหม่: 401 -> ยิง /auth/refresh -> สำเร็จก็ยิง request เดิมซ้ำ (ผู้ใช้ไม่รู้ตัว)
/// -> ไม่สำเร็จ (refresh หมดอายุ/ถูกเพิกถอน) ค่อย logout จริงแล้วเด้งหน้า login
void setupAuthInterceptor(
    Dio dio, {
      required AuthRepository authRepository,
      required TokenStorage tokenStorage,
      required AuthApiService authApi,
    }) {
  // 🔒 กัน refresh ซ้อน: ถ้ามีหลาย request ได้ 401 พร้อมกัน ต้องยิง refresh
  // "ครั้งเดียว" แล้วที่เหลือรอผลร่วมกัน ไม่งั้นจะ rotate ชนกันเอง แล้ว backend
  // จะตีความว่าเป็นการใช้ token ซ้ำ (reuse) แล้วเตะออกทุกเครื่อง
  Future<String?>? inflightRefresh;

  Future<String?> refreshOnce() {
    inflightRefresh ??= () async {
      try {
        final pair = await authApi.refresh(
          await tokenStorage.refreshToken,
          baseUrl: ApiConfig.baseUrl,
          headers: ApiConfig.defaultHeaders,
        );
        await tokenStorage.save(pair.accessToken, refreshToken: pair.refreshToken);
        return pair.accessToken;
      } catch (_) {
        return null;
      } finally {
        // เคลียร์ทีหลังสุด เพื่อให้ทุกคนที่รออยู่ได้ผลชุดเดียวกัน
        scheduleMicrotask(() => inflightRefresh = null);
      }
    }();
    return inflightRefresh!;
  }

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

        final isAuthEndpoint = path.contains('/auth/google') ||
            path.contains('/auth/logout') ||
            path.contains('/auth/refresh');

        // กันวนซ้ำ: request ที่ retry ไปแล้วรอบนึง ห้าม retry อีก
        final alreadyRetried = e.requestOptions.extra['__retried'] == true;

        if (status != 401 || isAuthEndpoint || alreadyRetried) {
          return handler.next(e);
        }

        final newToken = await refreshOnce();

        if (newToken == null) {
          // ต่ออายุไม่ได้จริงๆ = หมด session -> logout ผ่าน AuthState เพื่อให้
          // router (refreshListenable) เด้งไปหน้า login ให้ ไม่ค้างหน้าเดิม
          try {
            if (GetIt.I.isRegistered<AuthState>()) {
              await GetIt.I<AuthState>().logout();
            } else {
              await authRepository.logout();
            }
          } catch (_) {
            await authRepository.logout();
          }
          return handler.next(e);
        }

        // ต่ออายุสำเร็จ -> ยิง request เดิมซ้ำด้วย token ใหม่
        try {
          final req = e.requestOptions;
          req.headers['Authorization'] = 'Bearer $newToken';
          req.extra['__retried'] = true;

          final res = await dio.fetch(req);
          return handler.resolve(res);
        } catch (retryErr) {
          if (retryErr is DioException) return handler.next(retryErr);
          return handler.next(e);
        }
      },
    ),
  );
}
