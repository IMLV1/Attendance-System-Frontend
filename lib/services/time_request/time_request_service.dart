import 'package:attendance_system/services/time_request/time_request_model.dart';
import 'package:attendance_system/services/notification/notification_service.dart';
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


class TimeRequestService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> create(TimeRequestModel element, Uint8List? signature) async {

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

    if (signature != null) {
      MultipartFile signatureFile = MultipartFile.fromBytes(
        signature,
        filename: "signature.png",
        contentType: DioMediaType.parse("image/png"),
      );

      data['signature'] = signatureFile;
    }

    if (multipartFiles.isNotEmpty) {
      data['files'] = multipartFiles;
    }

    final response = await dio.post(
      '/api/attendance_request/create',
      data: FormData.fromMap(data),
    );

    return response;
  }

  Future<Response<dynamic>> resend(String id, String remark, List<NetworkFile> oldFiles, List<PlatformFile> files, Uint8List? signature) async {

    List<MultipartFile> multipartFiles = [];

    for (var file in files) {
      if (kIsWeb) {
        multipartFiles.add(MultipartFile.fromBytes(file.bytes!, filename: file.name));
      } else if (file.path != null) {
        multipartFiles.add(await MultipartFile.fromFile(file.path!, filename: file.name));
      }
    }

    FormData formData = FormData.fromMap({
      'id': id,
      'remark': remark,
      'old-files': oldFiles.map((f) => f.fileName).toList(),
      'files': multipartFiles,
      'signature': (signature != null) ? MultipartFile.fromBytes(
        signature,
        filename: "signature.png",
        contentType: DioMediaType.parse("image/png"),
      ) : null
    });

    return dio.put(
      '/api/attendance_request/resend',
      data: formData,
    );
  }

  Future<Response<dynamic>> getPending() async {
    return dio.get('/api/attendance_request/pending');
  }

  Future<Response<dynamic>> getRecent(DateTime? filterStartDate, DateTime? filterEndDate) async {
    return dio.get(
      '/api/attendance_request/recent',
      queryParameters: {
        if (filterStartDate != null)
          'startDate': filterStartDate.toIso8601String(),
        if (filterEndDate != null)
          'endDate': filterEndDate.toIso8601String(),
      },
    );
  }

  Future<Response<dynamic>> getFilterRange() async {
    return dio.get('/api/attendance_request/filter_range');
  }

  Future<Response<dynamic>> delete(String id) async {
    return dio.delete('/api/attendance_request/delete',
      data: {
        'id': id,
      }
    );
  }

  Future<Response<dynamic>> getDetail(String id) async {
    return dio.get('/api/attendance_request/detail',
      queryParameters: {
        'id': id,
      },
    );
  }
}