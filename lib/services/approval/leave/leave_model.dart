import '../../../features/main_feature/leave_request/leave_type.dart';
import '../../leave/leave_model.dart';
import '../../statistic/statistic_model.dart';
import '../attendance/attendance_model.dart';

class PendingLeaveApproval {
  final String userId;
  final String name;
  final String avatarUrl;
  int count;

  PendingLeaveApproval({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.count,
  });

  factory PendingLeaveApproval.fromJson(Map<String, dynamic> json) {
    return PendingLeaveApproval(
      userId: json['user-id'],
      name: json['name'],
      avatarUrl: json['avatar-url'],
      count: json['request-count'],
    );
  }

  static List<PendingLeaveApproval> getList(List data) {
    return data.map((e) => PendingLeaveApproval.fromJson(e)).toList();
  }
}

class RecentLeaveApproval {
  final String userId;
  final String name;
  final ApproveStatus status;
  final String requestId;
  final DateTime dateStart;
  final LeaveType type;

  RecentLeaveApproval({
    required this.userId,
    required this.name,
    required this.requestId,
    required this.status,
    required this.type,
    required this.dateStart,
  });

  factory RecentLeaveApproval.fromJson(Map<String, dynamic> json) {
    return RecentLeaveApproval(
      userId: json['user-id'],
      name: json['name'],
      requestId: json['request-id'],
      status: ApproveStatusX.fromState(json['status']),
      type: LeaveTypeX.fromString(json['type']),
      dateStart: DateTime.tryParse(json['date-start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static List<RecentLeaveApproval> getList(List data) {
    return data.map((e) => RecentLeaveApproval.fromJson(e)).toList();
  }
}

class PendingUserDetail {
  final String reqId;
  final LeaveType type;
  final DateTime dateStart;
  final DateTime dateEnd;

  PendingUserDetail({
    required this.reqId,
    required this.type,
    required this.dateStart,
    required this.dateEnd
  });

  factory PendingUserDetail.fromJson(Map<String, dynamic> json) {
    return PendingUserDetail(
        reqId: json['request-id'],
        type: LeaveTypeX.fromString(json['type']),
        dateStart: DateTime.tryParse(json['date-from']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        dateEnd: DateTime.tryParse(json['date-to']) ?? DateTime.fromMillisecondsSinceEpoch(0)
    );
  }

  static List<PendingUserDetail> getList(List data) {
    return data.map((e) => PendingUserDetail.fromJson(e)).toList();
  }
}

class LeaveApprovalModel {
  final UserDetail userDetail;
  final LeaveDetailModel leaveDetail;
  final List<PendingUserDetail> pendingUser;

  LeaveApprovalModel({
    required this.userDetail,
    required this.leaveDetail,
    required this.pendingUser
  });

  factory LeaveApprovalModel.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalModel(
      userDetail: UserDetail.fromJson(json['user-detail']),
      leaveDetail: LeaveDetailModel.fromJson(json['leave-info']),
      pendingUser: PendingUserDetail.getList(json['user-pending'])
    );
  }
}