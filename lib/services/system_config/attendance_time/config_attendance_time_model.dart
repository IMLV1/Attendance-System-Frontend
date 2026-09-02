import 'package:flutter/material.dart';

/// 🚩 (2026-09-03) ถอด `cutoff-time` (เวลาการตัดรอบวัน) ออกทั้งชุด
///
/// ตัวตั้งค่านี้บันทึกได้แต่ไม่มีผลอะไรเลย: ฝั่ง backend ไม่มีจุดไหนอ่านค่าไปใช้
/// (การตัดสินว่า "วันไหน" ใช้วันที่ปฏิทินตรงๆ ผ่าน time.Now() แล้ว format) ส่วน
/// ฝั่งแอปใช้แค่เคลียร์ตัวเลขบนหน้าจอตอนนาฬิกาตรงกับค่านั้นเป๊ะทั้งชั่วโมงและนาที
/// ซึ่งต้องเปิดหน้าค้างไว้พอดีในนาทีนั้นถึงจะทำงาน และถึงไม่ทำก็ไม่มีผล เพราะหน้า
/// ดึงข้อมูลของวันนี้จาก API อยู่แล้ว
///
/// ปล่อยไว้อันตรายกว่าไม่มี เพราะ admin ปรับแล้วเชื่อว่าตั้งได้จริง (รูปแบบเดียว
/// กับ auto-checkout ที่ถอดคำสัญญาออกไปแล้วเมื่อ 1 ก.ย.)
class ConfigAttendanceTimeModel {
  final TimeOfDay checkInTime;
  final TimeOfDay checkOutTime;

  final TimeOfDay checkInLeaveTime;
  final TimeOfDay checkOutLeaveTime;

  final bool autoCheckout;

  ConfigAttendanceTimeModel({
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInLeaveTime,
    required this.checkOutLeaveTime,
    required this.autoCheckout
  });

  factory ConfigAttendanceTimeModel.fromJson(Map<String, dynamic> json) {
    return ConfigAttendanceTimeModel(
      checkInTime: TimeOfDay(hour: json['check-in-time']?['hour'] ?? 0, minute: json['check-in-time']?['minute'] ?? 0),
      checkOutTime: TimeOfDay(hour: json['check-out-time']?['hour'] ?? 0, minute: json['check-out-time']?['minute'] ?? 0),
      checkInLeaveTime: TimeOfDay(hour: json['check-in-leave-time']?['hour'] ?? 0, minute: json['check-in-leave-time']?['minute'] ?? 0),
      checkOutLeaveTime: TimeOfDay(hour: json['check-out-leave-time']?['hour'] ?? 0, minute: json['check-out-leave-time']?['minute'] ?? 0),
      autoCheckout: json['auto-checkout'] ?? false,
    );
  }

  ConfigAttendanceTimeModel copyWith({
    TimeOfDay? checkInTime,
    TimeOfDay? checkOutTime,
    TimeOfDay? checkInLeaveTime,
    TimeOfDay? checkOutLeaveTime,
    bool? autoCheckout,
  }) {
    return ConfigAttendanceTimeModel(
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLeaveTime: checkInLeaveTime ?? this.checkInLeaveTime,
      checkOutLeaveTime: checkOutLeaveTime ?? this.checkOutLeaveTime,
      autoCheckout: autoCheckout ?? this.autoCheckout,
    );
  }

  bool isSame(ConfigAttendanceTimeModel other) {
    return

          checkInTime.hour == other.checkInTime.hour &&
          checkInTime.minute == other.checkInTime.minute &&

          checkOutTime.hour == other.checkOutTime.hour &&
          checkOutTime.minute == other.checkOutTime.minute &&

          checkInLeaveTime.hour == other.checkInLeaveTime.hour &&
          checkInLeaveTime.minute == other.checkInLeaveTime.minute &&

          checkOutLeaveTime.hour == other.checkOutLeaveTime.hour &&
          checkOutLeaveTime.minute == other.checkOutLeaveTime.minute &&

          autoCheckout == other.autoCheckout;
  }
}
