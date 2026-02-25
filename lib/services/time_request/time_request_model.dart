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

class AttendanceRequestModel {
  final String id;
  final DateTime dateStart;
  final DateTime dateEnd;
  final bool approved;

  const AttendanceRequestModel({
    required this.id,
    required this.dateStart,
    required this.dateEnd,
    required this.approved,
  });

  factory AttendanceRequestModel.fromJson(Map<String, dynamic> json) {

    return AttendanceRequestModel(

      id: json['id'] ?? '',
      dateStart: DateTime.tryParse(json['date-start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      dateEnd: DateTime.tryParse(json['date-end']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      approved: json['approved'] ?? false,
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