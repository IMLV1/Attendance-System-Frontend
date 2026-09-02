class StatisticModel {
  // --- ส่วนสรุป (Workday Card) ---
  final double totalWorkDays;    // วันทำงานทั้งหมด (แก้เป็น double)
  final double actualWorkDays;   // วันที่ต้องทำงานจริง (แก้เป็น double)

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
      // แปลงเป็น num ก่อนแล้วค่อย cast เป็น double เพื่อความปลอดภัย
        totalWorkDays: (json['total_work_days'] as num?)?.toDouble() ?? 0.0,
        actualWorkDays: (json['actual_work_days'] as num?)?.toDouble() ?? 0.0,
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
      // สมมติว่าฟิลด์นี้มาเป็น int เสมอ ถ้ามีโอกาสเป็นทศนิยมให้แก้แบบด้านบนครับ
      onTimeDays: (json['on_time_days'] as num?)?.toInt() ?? 0,
      lateDays: (json['late_days'] as num?)?.toInt() ?? 0,
      absentDays: (json['absent_days'] as num?)?.toInt() ?? 0,
    );
  }
}

class LeaveStatModel {
  // ปรับเป็น double ตาม JSON ที่บางครั้งส่งมาเป็น 0.5
  final double totalLeaveDays;   // ลางานทั้งหมด
  final double overLeaveDays;    // ลางานเกิน
  final LeaveDetailModel leaveDetails;

  LeaveStatModel({
    required this.totalLeaveDays,
    required this.overLeaveDays,
    required this.leaveDetails,
  });

  factory LeaveStatModel.fromJson(Map<String, dynamic> json) {
    return LeaveStatModel(
      totalLeaveDays: (json['total_leave_days'] as num?)?.toDouble() ?? 0.0,
      overLeaveDays: (json['over_leave_days'] as num?)?.toDouble() ?? 0.0,
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
  final LeaveTypeDetailModel ordination;
  final LeaveTypeDetailModel military;
  final LeaveTypeDetailModel rehabilitation;

  LeaveDetailModel({
    required this.sick,
    required this.personal,
    required this.vacation,
    required this.maternity,
    required this.paternity,
    required this.parental,
    required this.ordination,
    required this.military,
    required this.rehabilitation,
  });

  factory LeaveDetailModel.fromJson(Map<String, dynamic> json) {
    return LeaveDetailModel(
      sick: LeaveTypeDetailModel.fromJson(json['sick'] ?? {}),
      personal: LeaveTypeDetailModel.fromJson(json['personal'] ?? {}),
      vacation: LeaveTypeDetailModel.fromJson(json['vacation'] ?? {}),
      maternity: LeaveTypeDetailModel.fromJson(json['maternity'] ?? {}),
      paternity: LeaveTypeDetailModel.fromJson(json['paternity'] ?? {}),
      parental: LeaveTypeDetailModel.fromJson(json['parental'] ?? {}),
      ordination: LeaveTypeDetailModel.fromJson(json['ordination'] ?? {}),
      military: LeaveTypeDetailModel.fromJson(json['military'] ?? {}),
      rehabilitation: LeaveTypeDetailModel.fromJson(json['rehabilitation'] ?? {}),
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
      usedDays: (json['used_days'] as num?)?.toDouble() ?? 0.0,
      quotaDays: (json['quota_days'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WorkingHourModel {
  final double totalWorkingHour;
  final double totalAverageHour;
  final double weeklyWorkingHour;
  final double weeklyAverageHour;
  final double monthlyWorkingHour;
  final double monthlyAverageHour;
  final double yearlyWorkingHour;
  final double yearlyAverageHour;
  final Map<String, double> total;
  final Map<String, double> week;
  final Map<String, double> month;
  final Map<String, double> year;

  WorkingHourModel({
    required this.totalWorkingHour,
    required this.totalAverageHour,
    required this.weeklyWorkingHour,
    required this.weeklyAverageHour,
    required this.monthlyWorkingHour,
    required this.monthlyAverageHour,
    required this.yearlyWorkingHour,
    required this.yearlyAverageHour,
    required this.total,
    required this.week,
    required this.month,
    required this.year,
  });

  factory WorkingHourModel.fromJson(Map<String, dynamic> json) {

    // Updated to accept dynamic to prevent casting errors,
    // and safely checks if it's actually a Map before parsing.
    Map<String, double> castMap(dynamic map) {
      if (map == null || map is! Map) return {};
      return map.map<String, double>(
            (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
      );
    }

    return WorkingHourModel(
      // Safely cast all numbers via 'num' before converting to double
      totalWorkingHour: (json['total-working-hour'] as num?)?.toDouble() ?? 0.0,
      totalAverageHour: (json['total-average-hour'] as num?)?.toDouble() ?? 0.0,
      weeklyWorkingHour: (json['weekly-working-hour'] as num?)?.toDouble() ?? 0.0,
      weeklyAverageHour: (json['weekly-average-hour'] as num?)?.toDouble() ?? 0.0,
      monthlyWorkingHour: (json['monthly-working-hour'] as num?)?.toDouble() ?? 0.0,
      monthlyAverageHour: (json['monthly-average-hour'] as num?)?.toDouble() ?? 0.0,
      yearlyWorkingHour: (json['yearly-working-hour'] as num?)?.toDouble() ?? 0.0,
      yearlyAverageHour: (json['yearly-average-hour'] as num?)?.toDouble() ?? 0.0,

      // Safely parse the nested maps
      total: castMap(json['total']),
      week: castMap(json['week']),
      month: castMap(json['month']),
      year: castMap(json['year']),
    );
  }
}