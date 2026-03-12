import 'dart:ui';

import 'package:attendance_system/features/main_feature/leave_request/leave_type.dart';

// class LeaveModel {
//   final List<PendingLeaveRequestModel> pending;
//   final List<LeaveRequestModel> recent;
//
//   LeaveModel({
//     required this.pending,
//     required this.recent,
//   });
//
//   factory LeaveModel.fromJson(Map<String, dynamic> json) {
//     return LeaveModel(
//       pending: PendingLeaveRequestModel.getList(json['pending'] ?? []),
//       recent: LeaveRequestModel.getList(json['recent'] ?? []),
//     );
//   }
// }

class LeaveRequestModel {
  final String id;
  final LeaveType leaveType;
  final DateTime dateStart;
  final ApproveStatus status;

  const LeaveRequestModel({
    required this.id,
    required this.leaveType,
    required this.dateStart,
    required this.status
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] ?? '',
      leaveType: LeaveTypeX.fromString(json['leave-type'] ?? ''),
      dateStart: DateTime.tryParse(json['date-start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      status: ApproveStatusX.fromState(json['status'] ?? 'pending')
    );
  }

  static List<LeaveRequestModel> getList(List<dynamic> items) {
    return items.map((m) => LeaveRequestModel.fromJson(
      Map<String, dynamic>.from(m),
    )).toList();
  }
}

class PendingLeaveRequestModel {
  final String id;
  final LeaveType leaveType;
  final DateTime dateStart;

  const PendingLeaveRequestModel({
    required this.id,
    required this.leaveType,
    required this.dateStart,
  });

  factory PendingLeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return PendingLeaveRequestModel(
      id: json['id'] ?? '',
      leaveType: LeaveTypeX.fromString(json['leave-type'] ?? ''),
      dateStart: DateTime.tryParse(json['date-start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static List<PendingLeaveRequestModel> getList(List<dynamic> items) {
    return items.map((m) => PendingLeaveRequestModel.fromJson(
      Map<String, dynamic>.from(m),
    )).toList();
  }
}


class LeaveRequestDetailModel {
  final RequestDetail requestDetail;
  final ApproveDetail approveDetail;

  const LeaveRequestDetailModel({
    required this.requestDetail,
    required this.approveDetail,
  });

  factory LeaveRequestDetailModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestDetailModel(
      requestDetail: RequestDetail.fromJson(json['request-detail'] ?? {}),
      approveDetail: ApproveDetail.fromJson(json['approve-detail'] ?? {}),
    );
  }
}

class RequestDetail {
  final LeaveType leaveType;
  final DateTime dateFrom;
  final DateTime dateTo;
  final bool fromDateMorning;
  final bool toDateMorning;
  final String remark;
  final List<NetworkFile> evidenceFiles;
  final DateTime requestDate;

  const RequestDetail({
    required this.leaveType,
    required this.dateFrom,
    required this.dateTo,
    required this.fromDateMorning,
    required this.toDateMorning,
    required this.remark,
    required this.evidenceFiles,
    required this.requestDate,
  });

  factory RequestDetail.fromJson(Map<String, dynamic> json) {
    return RequestDetail(
      leaveType: LeaveTypeX.fromString(json['leave-type'] ?? ''),
      dateFrom: DateTime.tryParse(json['date-from']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      dateTo: DateTime.tryParse(json['date-to']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      fromDateMorning: json['from-date-morning'] ?? true,
      toDateMorning: json['to-date-morning'] ?? false,
      remark: json['remark'] ?? '',
      evidenceFiles: NetworkFile.getList(json['evidence-files'] ?? []),
      requestDate: DateTime.tryParse(json['request-date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class ApproveDetail {
  final ApproveStatus status;
  final String approver;
  final DateTime? approveDate;
  final String reason;
  final String approveRole;

  const ApproveDetail({
    required this.status,
    required this.approver,
    required this.approveDate,
    required this.reason,
    required this.approveRole,
  });

  factory ApproveDetail.fromJson(Map<String, dynamic> json) {
    return ApproveDetail(
      // Use your extension method for safety
      status: ApproveStatusX.fromState(json['status']),

      // Use ?? '' to handle nulls from the JSON
      approveRole: json['approve-role'] ?? '',
      approver: json['approver'] ?? '',
      reason: json['reason'] ?? '',

      // DateTime.tryParse already returns null safely,
      // and you're already handling it with DateTime.fromMillisecondsSinceEpoch(0)
      approveDate: DateTime.tryParse(json['approve-date'] ?? ''),
    );
  }
}

class NetworkFile {
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;

  const NetworkFile({
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize
  });

  factory NetworkFile.fromJson(Map<String, dynamic> json) {
    return NetworkFile(
      // Added null checks to prevent further crashes if keys are missing
      fileName: json['file-name'] ?? '',
      fileUrl: json['file-url'] ?? '',
      fileType: json['file-type'] ?? '',
      fileSize: json['file-size'] ?? 0,
    );
  }

  // Change parameter type from List<Map<String, dynamic>> to List<dynamic>
  static List<NetworkFile> getList(List<dynamic> items) {
    return items.map((item) => NetworkFile.fromJson(
      Map<String, dynamic>.from(item),
    )).toList();
  }
}

enum ApproveStatus { pending, approved, rejected, overdue, canceled }

extension ApproveStatusX on ApproveStatus {

  String get state => name;

  static ApproveStatus fromState(String? value) {
    if (value == null) {
      return ApproveStatus.pending;
    }

    return ApproveStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => ApproveStatus.pending,
    );
  }

  bool get isPending {
    return this == ApproveStatus.pending;
  }

  bool get isCompleted {
    return this != .pending;
  }

  String get icon {
    switch (this) {
      case ApproveStatus.approved:
        return 'icon_success.svg';

      case ApproveStatus.rejected:
        return 'icon_cancel.svg';

      case ApproveStatus.pending:
        return 'icon_pending.svg';

      case ApproveStatus.overdue:
        return 'icon_overdue.svg';

      case ApproveStatus.canceled:
        return 'icon_request_cancel.svg';
    }
  }

  Color get color {
    switch (this) {
      case ApproveStatus.pending:
        return const Color(0xFFE79E00);

      case ApproveStatus.approved:
        return const Color(0xFF30D143);

      case ApproveStatus.rejected:
        return const Color(0xFFE7000B);

      case ApproveStatus.overdue:
        return const Color(0xFF000000);

      case ApproveStatus.canceled:
        return const Color(0xFFFFA652);
    }
  }
}

class LeaveInfoModel {
  final double used;
  final double max;

  const LeaveInfoModel({required this.used, required this.max});

  factory LeaveInfoModel.fromJson(Map<String, dynamic> json) {
    return LeaveInfoModel(
      used: (json['used'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 0.0,
    );
  }
}