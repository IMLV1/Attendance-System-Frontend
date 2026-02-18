class AttendanceModel {
  final String? checkInTime;
  final String? checkOutTime;
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final String lastUpdateDate; // เอาไว้เช็คว่าข้อมูลที่โหลดมาเป็นของ "วันนี้" หรือไม่

  AttendanceModel({
    this.checkInTime = "---",
    this.checkOutTime = "---",
    this.hasCheckedIn = false,
    this.hasCheckedOut = false,
    required this.lastUpdateDate,
  });

  // แปลงเป็น JSON สำหรับส่งไป API หรือเก็บลง SharedPreferences
  Map<String, dynamic> toJson() => {
    'check_in_time': checkInTime,
    'check_out_time': checkOutTime,
    'has_checked_in': hasCheckedIn,
    'has_checked_out': hasCheckedOut,
    'last_update_date': lastUpdateDate,
  };

  // สร้าง Object จาก JSON ที่โหลดมาจากเครื่อง
  factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(
    checkInTime: json['check_in_time'],
    checkOutTime: json['check_out_time'],
    hasCheckedIn: json['has_checked_in'],
    hasCheckedOut: json['has_checked_out'],
    lastUpdateDate: json['last_update_date'],
  );
}