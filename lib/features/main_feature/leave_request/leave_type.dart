import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

enum LeaveType {sick, personal, vacation, maternity, paternity, parental}

extension LeaveTypeX on LeaveType {

  static LeaveType fromString(String value) {
    return LeaveType.values.firstWhere(
        (e) => e.name == value
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
        return 'ลาช่วยเหลือภริยาคลอดบุตร';
      case LeaveType.parental:
        return 'ลากิจเพื่อเลี้ยงดูบุตร';
    }
  }

  String get icon {
    switch (this) {
      case LeaveType.sick:
        return 'leave_sick.svg';
      case LeaveType.personal:
        return 'leave_personal.svg';
      case LeaveType.vacation:
        return 'icon_vacation.svg';
      case LeaveType.maternity:
        return 'icon_maternity.svg';
      case LeaveType.paternity:
        return 'icon_paternity.svg';
      case LeaveType.parental:
        return 'icon_parental.svg';
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
    }
  }
}