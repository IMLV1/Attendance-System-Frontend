import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../leave/leave_model.dart';

class TimeDate {
  final DateTime? fromDate;
  final DateTime? toDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  const TimeDate({
    this.fromDate,
    this.toDate,
    this.startTime,
    this.endTime,
  });
}

class TimeRequestModel {
  final DateTime? fromDate;
  final DateTime? toDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? remark;
  final List<PlatformFile>? files;

  const TimeRequestModel({
    this.fromDate,
    this.toDate,
    this.startTime,
    this.endTime,
    this.remark = '',
    this.files = const [],
  });

  TimeRequestModel copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? remark,
    List<PlatformFile>? files,
  }) {
    return TimeRequestModel(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      remark: remark ?? this.remark,
      files: files ?? this.files,
    );
  }
}

class AttendanceRequestModel {
  final String id;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String status;

  const AttendanceRequestModel({
    required this.id,
    required this.dateStart,
    required this.dateEnd,
    required this.status,
  });

  factory AttendanceRequestModel.fromJson(Map<String, dynamic> json) {

    return AttendanceRequestModel(

      id: json['id'] ?? '',
      dateStart: DateTime.tryParse(json['date-start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      dateEnd: DateTime.tryParse(json['date-end']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      status: json['status'] ?? '',
    );

  }

  static List<AttendanceRequestModel> getList(List<dynamic> items) {
    return items.map((m) => AttendanceRequestModel.fromJson(Map<String, dynamic>.from(m))).toList();
  }
}

class PendingAttendanceRequestModel {

  final String id;
  final DateTime dateStart;
  final DateTime dateEnd;

  const PendingAttendanceRequestModel({
    required this.id,
    required this.dateStart,
    required this.dateEnd,
  });

  factory PendingAttendanceRequestModel.fromJson(Map<String, dynamic> json) {
    return PendingAttendanceRequestModel(
      id: json['id'] ?? '',
      dateStart: DateTime.tryParse(json['date-start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      dateEnd: DateTime.tryParse(json['date-end']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static List<PendingAttendanceRequestModel> getList(List<dynamic> items) {
    return items.map((m) => PendingAttendanceRequestModel.fromJson(Map<String, dynamic>.from(m))).toList();
  }
}


class AttendanceDetail {
  final AttendanceRequestDetail requestDetail;
  final AttendanceApproveDetail approveDetail;

  AttendanceDetail({
    required this.requestDetail,
    required this.approveDetail,
  });

  factory AttendanceDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceDetail(
      requestDetail: AttendanceRequestDetail.fromJson(json['request-detail']),
      approveDetail: AttendanceApproveDetail.fromJson(json['approve-detail']),
    );
  }
}

class AttendanceRequestDetail {
  final DateTime dateFrom;
  final DateTime dateTo;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final String remark;
  final List<NetworkFile> evidenceFiles;

  AttendanceRequestDetail({
    required this.dateFrom,
    required this.dateTo,
    required this.timeStart,
    required this.timeEnd,
    required this.remark,
    required this.evidenceFiles,
  });

  factory AttendanceRequestDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceRequestDetail(
      dateFrom: DateTime.tryParse(json['date-from']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      dateTo: DateTime.tryParse(json['date-to']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      timeStart: _parseTime(json['time-start']),
      timeEnd: _parseTime(json['time-end']),
      remark: json['remark'] ?? '',
      evidenceFiles: (json['evidence-files'] as List? ?? []).map((e) => NetworkFile.fromJson(e)).toList(),
    );
  }

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: parts.length > 1 ? int.parse(parts[1]) : 0,
    );
  }
}

class AttendanceApproveDetail {
  final String status;
  final String approveRole;
  final String approver;
  final String reason;
  final DateTime? approveDate;

  AttendanceApproveDetail({
    required this.status,
    required this.approveRole,
    required this.approver,
    required this.reason,
    required this.approveDate,
  });

  factory AttendanceApproveDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceApproveDetail(
      status: json['status'] ?? '',
      approveRole: json['approve-role'] ?? '',
      approver: json['approver'] ?? '',
      reason: json['reason'] ?? '',
      approveDate: DateTime.tryParse(json['approve-date'] ?? ''),
    );
  }
}