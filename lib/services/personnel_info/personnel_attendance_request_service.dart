import 'package:attendance_system/services/time_request/time_request_model.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../leave/leave_model.dart';

String formatTimeOfDay(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
}


class PersonnelAttendanceRequestService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getPending(String personnelID) async {
    return dio.get(
      '/manager/personnel_info/attendance_request/pending',
      queryParameters: {
        'id': personnelID,
      }
    );
  }

  Future<Response<dynamic>> getRecent(String personnelID, DateTime? filterStartDate, DateTime? filterEndDate) async {
    return dio.get(
      '/manager/personnel_info/attendance_request/recent',
      queryParameters: {
        'id': personnelID,
        if (filterStartDate != null)
          'startDate': filterStartDate.toIso8601String(),
        if (filterEndDate != null)
          'endDate': filterEndDate.toIso8601String(),
      },
    );
  }

  Future<Response<dynamic>> getFilterRange(String personnelID) async {
    return dio.get(
      '/manager/personnel_info/attendance_request/filter_range',
      queryParameters: {
        'id': personnelID,
      },
    );
  }

  Future<Response<dynamic>> getDetail(String id) async {
    return dio.get('/manager/personnel_info/attendance_request/detail',
      queryParameters: {
        'request-id': id,
      },
    );
  }
}