import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class TimeRequestModel {
  final DateTime? fromDate;
  final DateTime? toDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String note;
  final List<PlatformFile> files;

  const TimeRequestModel({
    this.fromDate,
    this.toDate,
    this.startTime,
    this.endTime,
    this.note = '',
    this.files = const [],
  });

  TimeRequestModel copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? note,
    List<PlatformFile>? files,
  }) {

    return TimeRequestModel(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      note: note ?? this.note,
      files: files ?? this.files,
    );
  }
}
