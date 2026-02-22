import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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

enum AttendanceRequestStatus { pending, approved, rejected }

extension AttendanceRequestStatusX on AttendanceRequestStatus {

  String get state => name;

  static AttendanceRequestStatus fromState(String? value) {
    if (value == null) {
      return AttendanceRequestStatus.pending;
    }

    return AttendanceRequestStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => AttendanceRequestStatus.pending,
    );
  }

  bool get isPending {
    return this == AttendanceRequestStatus.pending;
  }

  bool get isCompleted {
    return this == AttendanceRequestStatus.approved ||
        this == AttendanceRequestStatus.rejected;
  }

  String get icon {
    switch (this) {
      case AttendanceRequestStatus.approved:
        return 'icon_success.svg';

      case AttendanceRequestStatus.rejected:
        return 'icon_cancel.svg';

      case AttendanceRequestStatus.pending:
        return 'icon_pending.svg';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceRequestStatus.pending:
        return const Color(0xFFE79E00);

      case AttendanceRequestStatus.approved:
        return const Color(0xFF30D143);

      case AttendanceRequestStatus.rejected:
        return const Color(0xFFE7000B);
    }
  }
}

class AttendanceRequestModel {

  final DateTime fromDate;
  final DateTime toDate;

  final TimeOfDay startTime;
  final TimeOfDay endTime;

  final String id;

  final AttendanceRequestStatus status;

  const AttendanceRequestModel({
    required this.fromDate,
    required this.toDate,
    required this.startTime,
    required this.endTime,
    required this.id,
    required this.status,
  });


  factory AttendanceRequestModel.fromJson(Map<String, dynamic> json) {
    final from = DateTime.parse(json['fromDate']);
    final to = DateTime.parse(json['toDate']);

    return AttendanceRequestModel(
      id: json['id'],
      status: AttendanceRequestStatusX.fromState(json['status'],),
      fromDate: from,
      toDate: to,
      startTime: _parseTime(json['startTime'],),
      endTime: _parseTime(json['endTime'],),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.state,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'startTime': _formatTime(startTime),
      'endTime': _formatTime(endTime),
    };
  }


  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class AttendanceRequestGrouper {

  static List<AttendanceRequestModel> pending(List<AttendanceRequestModel> list) {
    return list.where((e) => e.status.isPending).toList();
  }

  static List<AttendanceRequestModel> completed(List<AttendanceRequestModel> list) {
    return list.where((e) => e.status.isCompleted).toList();
  }
}