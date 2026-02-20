import 'package:attendance_system/core/data/api/api.dart';
import 'package:attendance_system/core/data/entities/time_request_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

String formatTimeOfDay(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:00';
}


class TimeRequestApi extends Api {

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

    return dio.post('api/attendance_request/create',
      data: FormData.fromMap(data),
    );
  }
}