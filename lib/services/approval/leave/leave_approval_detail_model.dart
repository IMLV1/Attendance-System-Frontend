import 'dart:ui';

import 'package:attendance_system/features/main_feature/leave_request/leave_type.dart';
import 'package:attendance_system/services/approval/attendance/attendance_model.dart';
import 'package:attendance_system/services/leave/leave_model.dart';


class LeaveApprovalDetailModel {
  final RequestDetail requestDetail;
  final ApproveDetail approveDetail;
  final UserDetail userDetail;

  const LeaveApprovalDetailModel({
    required this.requestDetail,
    required this.approveDetail,
    required this.userDetail,
  });

  factory LeaveApprovalDetailModel.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalDetailModel(
      requestDetail: RequestDetail.fromJson(json['request-detail'] ?? {}),
      approveDetail: ApproveDetail.fromJson(json['approve-detail'] ?? {}),
      userDetail: UserDetail.fromJson(json['user-detail']),
    );
  }
}