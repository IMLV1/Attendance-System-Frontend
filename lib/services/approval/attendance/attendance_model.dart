class PendingAttendanceApprovalModel {
  final String id;
  final String name;
  final String attendanceId;

  PendingAttendanceApprovalModel({
    required this.id,
    required this.name,
    required this.attendanceId,
  });

  factory PendingAttendanceApprovalModel.fromJson(Map<String, dynamic> json) {
    return PendingAttendanceApprovalModel(
      id: json['id'],
      name: json['name'],
      attendanceId: json['attendanceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'attendanceId': attendanceId,
    };
  }

  static List<PendingAttendanceApprovalModel> getList(List data) {
    return data.map((e) => PendingAttendanceApprovalModel.fromJson(e)).toList();
  }
}

class RecentAttendanceApprovalModel {
  final String id;
  final String status;
  final String name;
  final String attendanceId;

  RecentAttendanceApprovalModel({
    required this.id,
    required this.status,
    required this.name,
    required this.attendanceId,
  });

  factory RecentAttendanceApprovalModel.fromJson(Map<String, dynamic> json) {
    return RecentAttendanceApprovalModel(
      id: json['id'],
      status: json['status'],
      name: json['name'],
      attendanceId: json['attendanceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'name': name,
      'attendanceId': attendanceId,
    };
  }

  static List<RecentAttendanceApprovalModel> getList(List data) {
    return data.map((e) => RecentAttendanceApprovalModel.fromJson(e)).toList();
  }
}