import 'dart:typed_data';

import 'package:attendance_system/features/main_feature/leave_request/date_select.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/network/api_client.dart';

class LeaveRequestService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> create(String leaveType, LeaveDate leaveDate, String remark, List<PlatformFile> files, Uint8List signature) async {

    List<MultipartFile> multipartFiles = [];

    for (var file in files) {
      if (kIsWeb) {
        multipartFiles.add(
          MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        if (file.path != null) {
          multipartFiles.add(
            await MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            ),
          );
        }
      }
    }

    MultipartFile signatureFile = MultipartFile.fromBytes(
      signature,
      filename: "signature.png",
      contentType: DioMediaType.parse("image/png"),
    );

    var formData = FormData.fromMap({
      'leave-type': leaveType,
      'date-from': leaveDate.fromDate!.toIso8601String(),
      'date-to': leaveDate.toDate!.toIso8601String(),
      'from-date-morning': leaveDate.fromDateMorning,
      'to-date-morning': leaveDate.toDateMorning,
      'remark': remark,
      'files': multipartFiles,
      'signature': signatureFile
    });

    return dio.post('/api/leave_request/create',
      data: formData
    );
  }

  Future<Response<dynamic>> getPending() {
    return dio.get('/api/leave_status/pending');
  }

  Future<Response<dynamic>> getRecent(DateTime? filterStartDate, DateTime? filterEndDate) {
    return dio.get('/api/leave_status/recent',
      data: {
        'startDate': ?filterStartDate,
        'endDate': ?filterEndDate,
      }
    );
  }

  Future<Response<dynamic>> getFilterRange() {
    return dio.get('/api/leave_status/filter_range');
  }
}


