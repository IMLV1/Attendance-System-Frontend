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
