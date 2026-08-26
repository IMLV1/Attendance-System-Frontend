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

  /// 🚩 (2026-08-27) `init()` ต้อง **สรุปสถานะและ notify ให้ได้เสมอ** ไม่ว่าจะพัง
  /// ตรงไหน เพราะ router ใช้ `status` ตัดสินทาง ถ้ามันค้างที่ `unknown`
  /// redirect จะวนส่งกลับ `/splash` ตลอดกาล = แอปค้างที่หน้า splash เงียบๆ
  ///
  /// เจอจริงตอนเปิดเว็บจากมือถือผ่าน LAN (`http://192.168.x.x:5050`):
  /// `repo.hasToken()` เรียก flutter_secure_storage ซึ่งบนเว็บใช้ `crypto.subtle`
  /// และตัวมันโยน `UnsupportedError` ทันทีถ้า `window.isSecureContext == false`
  /// — ซึ่ง http ที่ไม่ใช่ localhost เข้าข่ายทั้งหมด exception หลุดออกมาก่อนถึง
  /// `notifyListeners()` ผู้ใช้เลยเห็นแต่หน้า splash ไม่มีวันไปถึงหน้า login
  ///
  /// (ก่อนหน้านี้ `init()` ถูก await ก่อน `runApp()` เคสนี้จึงพังแบบจอขาวแทน
  /// ที่จะค้าง — พังเหมือนกันแต่คนละอาการ)
  Future<void> init() async {
    try {
      final ok = await repo.hasToken();
      status = ok ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (e, s) {
      // อ่าน token ไม่ได้ = ไม่รู้ว่าเป็นใคร ให้ถือว่ายังไม่ล็อกอินแล้วพาไปหน้า login
      // ดีกว่าค้างอยู่เฉยๆ อย่างน้อยผู้ใช้ยังกดล็อกอินใหม่ได้
      debugPrint('🔴 AuthState.init: อ่านสถานะล็อกอินไม่ได้ — $e');
      debugPrint('🔴 stack: $s');
      status = AuthStatus.unauthenticated;
    }

    if (status == AuthStatus.authenticated) {
      try {
        user = await repo.getUser();
        await _loadUserContext();
      } catch (e) {
        // ตรงนี้ **ไม่** ลดสถานะกลับเป็น unauthenticated — token ใช้ได้อยู่ แค่
        // ข้อมูลประกอบโหลดไม่สำเร็จ (เน็ตสะดุด/เซิร์ฟเวอร์ล่ม) การเตะออกจากระบบ
        // เพราะเหตุนี้รุนแรงเกินไป แต่ละหน้ามีปุ่มลองใหม่ของตัวเองอยู่แล้ว
        debugPrint('🟠 AuthState.init: โหลดข้อมูลผู้ใช้ไม่สำเร็จ — $e');
      }
    }

    notifyListeners();
  }

  /// โหลดข้อมูลประกอบของผู้ใช้ที่เพิ่งยืนยันตัวตนแล้ว — โปรไฟล์ + config 3 ชุด
  ///
  /// 🚩 (2026-08-26) เดิมโค้ดชุดนี้ถูกก๊อปไว้สองที่ (`init` กับ `loginWithGoogle`)
  /// และยิงทีละตัวแบบ `await` เรียงกัน ทั้งที่ทั้ง 4 คำขอไม่ได้พึ่งผลของกันเลย
  /// เวลารวมจึงเป็น t1+t2+t3+t4 แทนที่จะเป็น max(t1..t4) — ซึ่งเห็นผลตรงๆ ตอน
  /// เปิดแอป เพราะ `main()` รอ `init()` ให้จบก่อน `runApp()` จอเลยขาวอยู่นานเท่านั้น
  ///
  /// อีกอย่างที่เจอตอนยุบรวม: สองที่นั้นเรียง config คนละลำดับกัน (init ยิง
  /// request ก่อน time / login ยิง time ก่อน request) ซึ่งไม่มีผลอะไรเพราะเป็น
  /// การอ่านล้วนๆ แต่เป็นสัญญาณว่าโค้ดสองชุดเริ่มเดินคนละทางแล้ว
  ///
  /// เรื่อง error ตั้งใจไม่แตะ: ถ้าตัวไหน throw ก็ยังโยนออกไปให้ผู้เรียกจัดการ
  /// เหมือนเดิม (`loginWithGoogle` จับไปทำ logout + ขึ้นข้อความ) ต่างจากเดิมแค่
  /// ตัวที่สำเร็จจะได้ค่าครบทุกตัว เพราะยิงไปพร้อมกันหมดแล้ว ไม่ได้หยุดที่ตัวแรกที่พัง
  Future<void> _loadUserContext() async {
    await Future.wait([
      _load(ProfileService().getProfile,
          (data) => profile = ProfileModel.fromJson(data)),
      _load(ConfigLeaveService().getData,
          (data) => leaveConfig = ConfigLeaveModel.fromJson(data)),
      _load(ConfigAttendanceRequestService().getData,
          (data) => attendanceConfig = ConfigAttendanceRequestModel.fromJson(data)),
      _load(ConfigAttendanceTimeService().getData,
          (data) => timeConfig = ConfigAttendanceTimeModel.fromJson(data)),
    ]);
  }

  /// ยิง 1 คำขอแล้ว assign ผลถ้าได้ 200 — ไม่ใช่ 200 ก็ปล่อยฟิลด์เป็น null
  /// ตามพฤติกรรมเดิมเป๊ะๆ (เดิมเป็น `if (response.statusCode == 200)` เฉยๆ)
  Future<void> _load(
    Future<Response> Function() request,
    void Function(dynamic data) assign,
  ) async {
    final response = await request();
    if (response.statusCode == 200) assign(response.data);
  }

  Future<String> loginWithGoogle() async {
    try {
      final result = await repo.loginWithGoogle();
      user = result.user;
      status = AuthStatus.authenticated;

      await _loadUserContext();

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