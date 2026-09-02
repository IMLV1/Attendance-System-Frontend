import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

enum LeaveType {sick, personal, vacation, maternity, paternity, parental,
  // 🚩 (2026-09-03) เพิ่มตามเอกสารสิทธิ์การลา ต้องตรงกับ name_en ใน leave_types
  ordination, military, rehabilitation}

extension LeaveTypeX on LeaveType {

  static LeaveType fromString(String value) {
    return LeaveType.values.firstWhere(
      (e) => e.name == value,
    );
  }

  String get display {
    switch (this) {
      case LeaveType.sick:
        return 'ลาป่วย';
      case LeaveType.personal:
        return 'ลากิจส่วนตัว';
      case LeaveType.vacation:
        return 'ลาพักผ่อน';
      case LeaveType.maternity:
        return 'ลาคลอดบุตร';
      case LeaveType.paternity:
        return 'ลาไปช่วยเหลือภริยาที่คลอดบุตร';
      case LeaveType.parental:
        return 'ลากิจเพื่อเลี้ยงดูบุตร';
      case LeaveType.ordination:
        return 'ลาอุปสมบทหรือการลาไปประกอบพิธีฮัจย์';
      case LeaveType.military:
        return 'ลาเข้ารับการตรวจเลือกเตรียมทหาร';
      case LeaveType.rehabilitation:
        return 'ลาไปฟื้นฟูสมรรถภาพด้านอาชีพ';
    }
  }

  String get icon {
    switch (this) {
      case LeaveType.sick: return 'leave_sick.svg';
      case LeaveType.personal: return 'leave_personal.svg';
      case LeaveType.vacation: return 'leave_vacation.svg';
      case LeaveType.maternity:
        return 'leave_maternity.svg';
      case LeaveType.paternity:
        return 'leave_paternity.svg';
      case LeaveType.parental:
        return 'leave_parental.svg';
      // ยังไม่มีไอคอนเฉพาะของสามประเภทนี้ ใช้ไอคอนกลางไปก่อน
      case LeaveType.ordination:
      case LeaveType.military:
      case LeaveType.rehabilitation:
        return 'leave.svg';
    }
  }

  LeaveSetting? getSetting(BuildContext context) {

    ConfigLeaveModel? config = context.read<AuthState>().leaveConfig;

    switch (this) {
      case LeaveType.sick:
        return config?.sick;
      case LeaveType.personal:
        return config?.personal;
      case LeaveType.vacation:
        return config?.vacation;
      case LeaveType.maternity:
        return config?.maternity;
      case LeaveType.paternity:
        return config?.paternity;
      case LeaveType.parental:
        return config?.parental;
      case LeaveType.ordination:
        return config?.ordination;
      case LeaveType.military:
        return config?.military;
      case LeaveType.rehabilitation:
        return config?.rehabilitation;
    }
  }
}