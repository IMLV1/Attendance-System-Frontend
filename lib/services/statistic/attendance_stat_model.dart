class StatisticModel {
  // --- ส่วนสรุป (Workday Card) ---
  final int totalWorkDays;    // วันทำงานทั้งหมด
  final int actualWorkDays;   // วันที่ต้องทำงานจริง

  final AttendanceStatModel attendanceDetail;

  // --- ส่วนสรุปการลางาน (Leave Summary) ---
  final LeaveStatModel leaveDetail;

  StatisticModel({
    required this.totalWorkDays,
    required this.actualWorkDays,
    required this.attendanceDetail,
    required this.leaveDetail,
  });

  // ฟังก์ชันแปลง JSON จาก Backend เป็น Object
  factory StatisticModel.fromJson(Map<String, dynamic> json) {
    return StatisticModel(
      totalWorkDays: json['total_work_days'] ?? 0,
      actualWorkDays: json['actual_work_days'] ?? 0,
      attendanceDetail: AttendanceStatModel.fromJson(json['attendance_detail'] ?? {}),
      leaveDetail: LeaveStatModel.fromJson(json['leave_detail'] ?? {})
    );
  }
}

class AttendanceStatModel {
  final int onTimeDays;       // จำนวนวันตรงเวลา
  final int lateDays;         // จำนวนวันมาสาย
  final int absentDays;       // จำนวนวันขาดงาน

  AttendanceStatModel({
    required this.onTimeDays,
    required this.lateDays,
    required this.absentDays,
  });

  factory AttendanceStatModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatModel(
      onTimeDays: json['on_time_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
    );
  }
}

class LeaveStatModel {
  final int totalLeaveDays;   // ลางานทั้งหมด
  final int overLeaveDays;    // ลางานเกิน
  final LeaveDetailModel leaveDetails;

  LeaveStatModel({
    required this.totalLeaveDays,
    required this.overLeaveDays,
    required this.leaveDetails,
  });

  factory LeaveStatModel.fromJson(Map<String, dynamic> json) {
    return LeaveStatModel(
      totalLeaveDays: json['total_leave_days'] ?? 0,
      overLeaveDays: json['over_leave_days'] ?? 0,
      leaveDetails: LeaveDetailModel.fromJson(json['leaves'] ?? {}),
    );
  }
}

class LeaveDetailModel {
  final LeaveTypeDetailModel sick;      
  final LeaveTypeDetailModel personal;  
  final LeaveTypeDetailModel vacation;
  final LeaveTypeDetailModel maternity;
  final LeaveTypeDetailModel paternity;
  final LeaveTypeDetailModel parental;

  LeaveDetailModel({
    required this.sick,
    required this.personal,
    required this.vacation,
    required this.maternity,
    required this.paternity,
    required this.parental,
  });

  factory LeaveDetailModel.fromJson(Map<String, dynamic> json) {
    return LeaveDetailModel(
      sick: LeaveTypeDetailModel.fromJson(json['sick'] ?? {}),
      personal: LeaveTypeDetailModel.fromJson(json['personal'] ?? {}),
      vacation: LeaveTypeDetailModel.fromJson(json['vacation'] ?? {}),
      maternity: LeaveTypeDetailModel.fromJson(json['maternity'] ?? {}),
      paternity: LeaveTypeDetailModel.fromJson(json['paternity'] ?? {}),
      parental: LeaveTypeDetailModel.fromJson(json['parental'] ?? {}),
    );
  }
}

class LeaveTypeDetailModel {
  final double usedDays;
  final double quotaDays;

  LeaveTypeDetailModel({
    required this.usedDays,
    required this.quotaDays,
  });

  factory LeaveTypeDetailModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeDetailModel(
      usedDays: json['used_days'] ?? 0.0,
      quotaDays: json['quota_days'] ?? 0.0,
    );
  }
}