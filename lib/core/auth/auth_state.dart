import 'package:attendance_system/core/auth/user_model.dart';
import 'package:attendance_system/services/profile_page/profile_model.dart';
import 'package:attendance_system/services/profile_page/profile_service.dart';
import 'package:attendance_system/services/system_config/attendance_request/config_attendance_request_model.dart';
import 'package:attendance_system/services/system_config/attendance_request/config_attendance_request_service.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_model.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_service.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_model.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends ChangeNotifier {
  final AuthRepository repo;

  AuthStatus status = AuthStatus.unknown;

  UserModel? user;
  ProfileModel? profile;
  ConfigLeaveModel? leaveConfig;
  ConfigAttendanceTimeModel? timeConfig;
  ConfigAttendanceRequestModel? attendanceConfig;

  AuthState(this.repo);

  bool get isLoggedIn => status == AuthStatus.authenticated;

  Future<void> init() async {
    final ok = await repo.hasToken();
    status = ok ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    if (status == AuthStatus.authenticated) {
      user = await repo.getUser();

      {
        Response response = await ProfileService().getProfile();
        if (response.statusCode == 200) {
          profile = ProfileModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigLeaveService().getData();
        if (response.statusCode == 200) {
          leaveConfig = ConfigLeaveModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigAttendanceRequestService().getData();
        if (response.statusCode == 200) {
          attendanceConfig = ConfigAttendanceRequestModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigAttendanceTimeService().getData();
        if (response.statusCode == 200) {
          timeConfig = ConfigAttendanceTimeModel.fromJson(response.data);
        }
      }
    }

    notifyListeners();
  }

  Future<String> loginWithGoogle() async {
    try {
      final result = await repo.loginWithGoogle();
      user = result.user;
      status = AuthStatus.authenticated;

      {
        Response response = await ProfileService().getProfile();
        if (response.statusCode == 200) {
          profile = ProfileModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigLeaveService().getData();
        if (response.statusCode == 200) {
          leaveConfig = ConfigLeaveModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigAttendanceTimeService().getData();
        if (response.statusCode == 200) {
          timeConfig = ConfigAttendanceTimeModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigAttendanceRequestService().getData();
        if (response.statusCode == 200) {
          attendanceConfig = ConfigAttendanceRequestModel.fromJson(response.data);
        }
      }

      return '';
    } catch (e, s) {
      debugPrint('🔴 loginWithGoogle error: $e');
      debugPrint('🔴 stack: $s');
      status = AuthStatus.unauthenticated;
      await logout();

      // ผู้ใช้กดยกเลิกหน้าเลือกบัญชีเอง ไม่ใช่ error — ไม่ต้องขึ้นข้อความแดง
      if (e is LoginCancelled) return '';

      return _loginErrorMessage(e);
    } finally {
      notifyListeners();
    }
  }

  /// 🚩 (2026-08-23) แปลง exception เป็นข้อความที่บอก "สาเหตุจริง" ให้ผู้ใช้เห็น
  ///
  /// เดิมตอบข้อความเดียวกันหมดทุกกรณี ทำให้แยกไม่ออกว่าต่อเซิร์ฟเวอร์ไม่ติด,
  /// token Google มีปัญหา หรือบัญชียังไม่ได้ลงทะเบียน (ซึ่งวิธีแก้คนละเรื่องกัน)
  String _loginErrorMessage(Object e) {
    if (e is! LoginFailure) {
      return 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
    }

    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้\nกรุณาตรวจสอบอินเทอร์เน็ตแล้วลองใหม่อีกครั้ง';
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'เซิร์ฟเวอร์ตอบกลับช้าเกินไป กรุณาลองใหม่อีกครั้ง';
      default:
        break;
    }

    // บอกไปด้วยว่าล็อกอินด้วยบัญชีไหน — เคสที่เจอบ่อยคือ Google เลือกบัญชี
    // ส่วนตัวให้อัตโนมัติ ทั้งที่ต้องใช้บัญชีที่ HR ลงทะเบียนไว้
    final account = e.email == null ? '' : '\n(บัญชี ${e.email})';
    final backend = e.backendError ?? '';

    if (e.statusCode == 401) {
      if (backend.contains('not registered')) {
        return 'บัญชีนี้ยังไม่ได้ลงทะเบียนในระบบ กรุณาติดต่อฝ่ายบุคคล$account';
      }
      if (backend.contains('Google')) {
        return 'ยืนยันตัวตนกับ Google ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง$account';
      }
      return 'ไม่มีสิทธิ์เข้าใช้ระบบ กรุณาติดต่อฝ่ายบุคคล$account';
    }

    if (e.statusCode != null && e.statusCode! >= 500) {
      return 'เซิร์ฟเวอร์มีปัญหา (${e.statusCode}) กรุณาลองใหม่ภายหลัง';
    }

    if (e.statusCode != null) {
      return 'เข้าสู่ระบบไม่สำเร็จ (HTTP ${e.statusCode})\nกรุณาติดต่อฝ่ายบุคคล$account';
    }

    return 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
  }

  Future<void> logout() async {
    await repo.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}