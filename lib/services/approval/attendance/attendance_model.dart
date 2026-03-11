import '../../time_request/time_request_model.dart';

class PendingAttendanceApprovalModel {
  final String name;
  final String attendanceId;

  PendingAttendanceApprovalModel({
    required this.name,
    required this.attendanceId,
  });

  factory PendingAttendanceApprovalModel.fromJson(Map<String, dynamic> json) {
    return PendingAttendanceApprovalModel(
      name: json['name'],
      attendanceId: json['attendanceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'attendanceId': attendanceId,
    };
  }

  static List<PendingAttendanceApprovalModel> getList(List data) {
    return data.map((e) => PendingAttendanceApprovalModel.fromJson(e)).toList();
  }
}

class RecentAttendanceApprovalModel {
  final String status;
  final String name;
  final String attendanceId;

  RecentAttendanceApprovalModel({
    required this.status,
    required this.name,
    required this.attendanceId,
  });

  factory RecentAttendanceApprovalModel.fromJson(Map<String, dynamic> json) {
    return RecentAttendanceApprovalModel(
      status: json['status'],
      name: json['name'],
      attendanceId: json['attendanceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'name': name,
      'attendanceId': attendanceId,
    };
  }

  static List<RecentAttendanceApprovalModel> getList(List data) {
    return data.map((e) => RecentAttendanceApprovalModel.fromJson(e)).toList();
  }
}

class AttendanceApprovalModel {
  final AttendanceRequestDetail requestDetail;
  final AttendanceApproveDetail approveDetail;
  final UserDetail userDetail;

  AttendanceApprovalModel({
    required this.requestDetail,
    required this.approveDetail,
    required this.userDetail,
  });

  factory AttendanceApprovalModel.fromJson(Map<String, dynamic> json) {
    return AttendanceApprovalModel(
      requestDetail: AttendanceRequestDetail.fromJson(json['request-detail']),
      approveDetail: AttendanceApproveDetail.fromJson(json['approve-detail']),
      userDetail: UserDetail.fromJson(json['user-detail']),
    );
  }
}

class UserDetail {
  final String avatarUrl;
  final String name;
  final String initRole;

  UserDetail({
    required this.avatarUrl,
    required this.name,
    required this.initRole,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      avatarUrl: json['avatar-url'],
      name: json['name'],
      initRole: json['init-role'],
    );
  }
}