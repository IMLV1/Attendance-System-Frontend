import 'package:attendance_system/core/auth/auth_repository.dart';
import 'package:attendance_system/core/auth/auth_result.dart';
import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/core/auth/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// 🚩 (2026-08-27) กันบั๊ก "ค้างที่หน้า splash ตลอดกาล"
///
/// router ใช้ `AuthState.status` ตัดสินทาง และ `unknown` แปลว่า "ยังไม่รู้" ซึ่ง
/// redirect จะส่งกลับ `/splash` เสมอ ดังนั้น `init()` ที่จบแบบไม่สรุปสถานะ
/// (เช่นมี exception หลุดออกมาก่อนถึง notifyListeners) = แอปค้างเงียบๆ
/// ไม่มีทางไปถึงหน้า login
///
/// เจอจริงตอนเปิดเว็บผ่าน LAN: flutter_secure_storage บนเว็บโยน UnsupportedError
/// ทันทีถ้าไม่ใช่ secure context (http ที่ไม่ใช่ localhost)
class _ThrowingRepo implements AuthRepository {
  final Object error;
  _ThrowingRepo(this.error);

  @override
  Future<bool> hasToken() async => throw error;

  @override
  Future<UserModel?> getUser() async => null;

  @override
  Future<AuthResult> loginWithGoogle() async => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> forceLogout() async {}
}

class _TokenOkRepo implements AuthRepository {
  @override
  Future<bool> hasToken() async => true;

  /// จำลองเน็ตสะดุดตอนดึงข้อมูลผู้ใช้ — ไม่ควรถูกเตะออกจากระบบเพราะเหตุนี้
  @override
  Future<UserModel?> getUser() async => throw Exception('เชื่อมต่อไม่ได้');

  @override
  Future<AuthResult> loginWithGoogle() async => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> forceLogout() async {}
}

void main() {
  test('อ่าน token ไม่ได้ -> ไม่ค้างที่ unknown แต่ไปเป็น unauthenticated', () async {
    final auth = AuthState(_ThrowingRepo(
      UnsupportedError('FlutterSecureStorageWeb only works in secure contexts'),
    ));

    var notified = 0;
    auth.addListener(() => notified++);

    await auth.init();

    expect(auth.status, AuthStatus.unauthenticated,
        reason: 'ถ้ายังเป็น unknown redirect จะวนส่งกลับ /splash ตลอดกาล');
    expect(notified, greaterThan(0),
        reason: 'ต้อง notify เสมอ ไม่งั้น GoRouter จะไม่ประเมิน redirect ใหม่');
  });

  test('มี token แต่โหลดข้อมูลผู้ใช้พัง -> ยังถือว่าล็อกอินอยู่', () async {
    final auth = AuthState(_TokenOkRepo());

    var notified = 0;
    auth.addListener(() => notified++);

    await auth.init();

    expect(auth.status, AuthStatus.authenticated,
        reason: 'เน็ตสะดุดตอนดึงโปรไฟล์ ไม่ใช่เหตุผลที่จะเตะผู้ใช้ออกจากระบบ');
    expect(notified, greaterThan(0));
  });
}
