import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:attendance_system/services/time_request/time_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// สิทธิ์อนุมัติต้องมาจาก backend รายคำขอ ไม่ใช่เดาจาก role type รวมของผู้ใช้
///
/// เคสสำคัญคือ default ตอน field หายไป (backend เก่า / response ไม่ครบ):
/// ต้องเป็น false — ยอมซ่อนปุ่มผิดพลาดดีกว่าโชว์ปุ่มที่กดแล้วได้ 403
void main() {
  Map<String, dynamic> leaveJson(Map<String, dynamic> extra) => {
        'status': 'pending',
        'approve-role': 'หัวหน้าภาค',
        'approver': '',
        'reason': '',
        'approve-date': '',
        ...extra,
      };

  group('ApproveDetail (ใบลา)', () {
    test('can-approve: true -> canApprove true', () {
      expect(ApproveDetail.fromJson(leaveJson({'can-approve': true})).canApprove, isTrue);
    });

    test('can-approve: false -> canApprove false', () {
      expect(ApproveDetail.fromJson(leaveJson({'can-approve': false})).canApprove, isFalse);
    });

    test('ไม่มี field เลย -> false (ไม่ใช่ true)', () {
      expect(ApproveDetail.fromJson(leaveJson({})).canApprove, isFalse);
    });

    test('null -> false', () {
      expect(ApproveDetail.fromJson(leaveJson({'can-approve': null})).canApprove, isFalse);
    });

    test('ค่าที่ไม่ใช่ bool ไม่ถูกตีเป็น true', () {
      // เผื่อ backend เปลี่ยนไปส่งสตริง — ต้องไม่กลายเป็นอนุญาตโดยบังเอิญ
      expect(ApproveDetail.fromJson(leaveJson({'can-approve': 'true'})).canApprove, isFalse);
      expect(ApproveDetail.fromJson(leaveJson({'can-approve': 1})).canApprove, isFalse);
    });
  });

  group('AttendanceApproveDetail (แก้ไขเวลา)', () {
    Map<String, dynamic> attJson(Map<String, dynamic> extra) => {
          'status': 'pending',
          'approve-role': '',
          'approver': '',
          'reason': '',
          'approve-date': '',
          ...extra,
        };

    test('can-approve: true -> canApprove true', () {
      expect(AttendanceApproveDetail.fromJson(attJson({'can-approve': true})).canApprove, isTrue);
    });

    test('ไม่มี field เลย -> false', () {
      expect(AttendanceApproveDetail.fromJson(attJson({})).canApprove, isFalse);
    });
  });
}
