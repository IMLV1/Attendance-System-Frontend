
import 'package:flutter/material.dart';

class ConfigAttendanceTimeModel {
  final TimeOfDay cutoffTime;
  final TimeOfDay checkInTime;
  final TimeOfDay checkOutTime;

  final TimeOfDay checkInLeaveTime;
  final TimeOfDay checkOutLeaveTime;

  final bool autoCheckout;

  ConfigAttendanceTimeModel({
    required this.cutoffTime,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInLeaveTime,
    required this.checkOutLeaveTime,
    required this.autoCheckout
  });

  factory ConfigAttendanceTimeModel.fromJson(Map<String, dynamic> json) {
    return ConfigAttendanceTimeModel(
      cutoffTime: TimeOfDay(hour: json['cutoff-time']?['hour'] ?? 0, minute: json['cutoff-time']?['minute'] ?? 0),
      checkInTime: TimeOfDay(hour: json['check-in-time']?['hour'] ?? 0, minute: json['check-in-time']?['minute'] ?? 0),
      checkOutTime: TimeOfDay(hour: json['check-out-time']?['hour'] ?? 0, minute: json['check-out-time']?['minute'] ?? 0),
      checkInLeaveTime: TimeOfDay(hour: json['check-in-leave-time']?['hour'] ?? 0, minute: json['check-in-leave-time']?['minute'] ?? 0),
      checkOutLeaveTime: TimeOfDay(hour: json['check-out-leave-time']?['hour'] ?? 0, minute: json['check-out-leave-time']?['minute'] ?? 0),
      autoCheckout: json['auto-checkout'] ?? false,
    );
  }

  ConfigAttendanceTimeModel copyWith({
    TimeOfDay? cutoffTime,
    TimeOfDay? checkInTime,
    TimeOfDay? checkOutTime,
    TimeOfDay? checkInLeaveTime,
    TimeOfDay? checkOutLeaveTime,
    bool? autoCheckout,
  }) {
    return ConfigAttendanceTimeModel(
      cutoffTime: cutoffTime ?? this.cutoffTime,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLeaveTime: checkInLeaveTime ?? this.checkInLeaveTime,
      checkOutLeaveTime: checkOutLeaveTime ?? this.checkOutLeaveTime,
      autoCheckout: autoCheckout ?? this.autoCheckout,
    );
  }

  bool isSame(ConfigAttendanceTimeModel other) {
    return
      cutoffTime.hour == other.cutoffTime.hour &&
          cutoffTime.minute == other.cutoffTime.minute &&

          checkInTime.hour == other.checkInTime.hour &&
          checkInTime.minute == other.checkInTime.minute &&

          checkOutTime.hour == other.checkOutTime.hour &&
          checkOutTime.minute == other.checkOutTime.minute &&

          checkInLeaveTime.hour == other.checkInLeaveTime.hour &&
          checkInLeaveTime.minute == other.checkInLeaveTime.minute &&

          checkOutLeaveTime.hour == other.checkOutLeaveTime.hour &&
          checkOutLeaveTime.minute == other.checkOutLeaveTime.minute &&

          autoCheckout == other.autoCheckout;
  }
}
