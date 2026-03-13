class AttendanceLeaveModel {
  final bool isApproved;
  final String leaveType; // FULL_DAY, MORNING, AFTERNOON, NONE
  final String leaveName;

  AttendanceLeaveModel({
    required this.isApproved,
    required this.leaveType,
    required this.leaveName,
  });

  factory AttendanceLeaveModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLeaveModel(
      isApproved: json['is_approved'] ?? false,
      leaveType: json['leave_type'] ?? "NONE",
      leaveName: json['leave_name'] ?? "",
    );
  }
}