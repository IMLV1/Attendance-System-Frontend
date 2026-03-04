class AttendanceStatModel {
  // --- ส่วนสรุป (Workday Card) ---
  final int totalWorkDays;    // วันทำงานทั้งหมด
  final int actualWorkDays;   // วันที่ต้องทำงานจริง

  // --- ส่วนสถิติเข้างาน (Attendance Rate / Circular Chart) ---
  final double onTimePercent; // % ตรงเวลา
  final int onTimeDays;       // จำนวนวันตรงเวลา
  final int lateDays;         // จำนวนวันมาสาย
  final int absentDays;       // จำนวนวันขาดงาน

  // --- ส่วนสรุปการลางาน (Leave Summary) ---
  final int totalLeaveDays;   // ลางานทั้งหมด
  final int overLeaveDays;    // ลางานเกิน
  final List<LeaveDetailModel> leaveDetails; // รายการลาแต่ละประเภท (ลาป่วย, ลากิจ ฯลฯ)

  AttendanceStatModel({
    required this.totalWorkDays,
    required this.actualWorkDays,
    required this.onTimePercent,
    required this.onTimeDays,
    required this.lateDays,
    required this.absentDays,
    required this.totalLeaveDays,
    required this.overLeaveDays,
    required this.leaveDetails,
  });

  // ฟังก์ชันแปลง JSON จาก Backend เป็น Object
  factory AttendanceStatModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatModel(
      totalWorkDays: json['total_work_days'] ?? 0,
      actualWorkDays: json['actual_work_days'] ?? 0,
      onTimePercent: (json['on_time_percent'] ?? 0).toDouble(),
      onTimeDays: json['on_time_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      totalLeaveDays: json['total_leave_days'] ?? 0,
      overLeaveDays: json['over_leave_days'] ?? 0,
      leaveDetails: (json['leave_details'] as List? ?? [])
          .map((i) => LeaveDetailModel.fromJson(i))
          .toList(),
    );
  }
}

class LeaveDetailModel {
  final String label;      // ชื่อประเภทการลา (เช่น ลาป่วย)
  final double usedDays;   // จำนวนวันที่ใช้ไป
  final double quotaDays;  // โควตาทั้งหมด

  LeaveDetailModel({
    required this.label,
    required this.usedDays,
    required this.quotaDays,
  });

  factory LeaveDetailModel.fromJson(Map<String, dynamic> json) {
    return LeaveDetailModel(
      label: json['label'] ?? '',
      usedDays: (json['used_days'] ?? 0).toDouble(),
      quotaDays: (json['quota_days'] ?? 0).toDouble(),
    );
  }
}