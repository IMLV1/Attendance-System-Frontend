import 'package:attendance_system/services/time_request/time_request_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

String formatTimeOfDay(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:00';
}


class TimeRequestService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> timeRequestCreate(TimeRequestModel element) async {

    List<MultipartFile> multipartFiles = [];

    for (var file in element.files ?? []) {
      if (kIsWeb) {
        multipartFiles.add(
          MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        );
      } else if (file.path != null) {
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          ),
        );
      }
    }

    Map<String, dynamic> data = {
      'date-from': element.fromDate!.toIso8601String(),
      'date-to': element.toDate!.toIso8601String(),
      'start-time': formatTimeOfDay(element.startTime!),
      'end-time': formatTimeOfDay(element.endTime!),
      'remark': element.remark ?? '',
    };

    if (multipartFiles.isNotEmpty) {
      data['files'] = multipartFiles;
    }

    return dio.post('/api/attendance_request/create',
      data: FormData.fromMap(data),
    );
  }

  Future<Response<dynamic>> getAttendanceRequest() async {
    return dio.get('/api/attendance_request/get');
  }
}