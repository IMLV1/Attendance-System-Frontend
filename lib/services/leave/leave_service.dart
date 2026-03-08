import 'dart:typed_data';

import 'package:attendance_system/features/main_feature/leave_request/date_select.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_type.dart';
import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:attendance_system/services/notification/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/network/api_client.dart';

class LeaveRequestService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> create(LeaveType leaveType, LeaveDate leaveDate, String remark, List<PlatformFile> files, Uint8List? signature) async {

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

    var formData = FormData.fromMap({
      'leave-type': leaveType.name,
      'date-from': leaveDate.fromDate!.toIso8601String(),
      'date-to': leaveDate.toDate!.toIso8601String(),
      'from-date-morning': leaveDate.fromDateMorning,
      'to-date-morning': leaveDate.toDateMorning,
      'remark': remark,
      'files': multipartFiles,
      'signature': signature != null ? MultipartFile.fromBytes(
        signature,
        filename: "signature.png",
        contentType: DioMediaType.parse("image/png"),
      ) : null
    });

    final response = await dio.post('/api/leave_request/create',
      data: formData
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final String? requestNumber = response.data['request-number'] ?? response.data['requestNumber'];
      if (requestNumber != null) {
        NotificationService().sendRequestNotification('APPROVER_LEAVE', requestNumber);
      }
    }

    return response;
  }

  Future<Response<dynamic>> getPending() {
    return dio.get('/api/leave_status/pending');
  }

  Future<Response<dynamic>> getRecent(DateTime? filterStartDate, DateTime? filterEndDate) {

    return dio.get(
      '/api/leave_status/recent',
      queryParameters: {
        if (filterStartDate != null)
          'startDate': filterStartDate.toIso8601String(),
        if (filterEndDate != null)
          'endDate': filterEndDate.toIso8601String(),
      },
    );
  }

  Future<Response<dynamic>> getFilterRange() {
    return dio.get('/api/leave_status/filter_range');
  }

  Future<Response<dynamic>> getRequestDetail(String requestId) {
    return dio.get(
      '/api/leave_status/detail',
      queryParameters: {
        'request-id': requestId,
      },
    );
  }

  Future<Response<dynamic>> cancelRequest(String requestId) {
    return dio.delete(
      '/api/leave_request/cancel',
      data: {
        'request-id': requestId
      }
    );
  }

  Future<Response<dynamic>> resendRequest(String requestId, String remark, List<NetworkFile> oldFiles, List<PlatformFile> files, Uint8List? signature) async {

    // 1. Initialize your file list
    List<MultipartFile> multipartFiles = [];

    for (var file in files) {
      if (kIsWeb) {
        multipartFiles.add(MultipartFile.fromBytes(file.bytes!, filename: file.name));
      } else if (file.path != null) {
        multipartFiles.add(await MultipartFile.fromFile(file.path!, filename: file.name));
      }
    }

    // 2. Wrap everything in FormData
    FormData formData = FormData.fromMap({
      'request-id': requestId,
      'remark': remark,
      'old-files': oldFiles.map((f) => f.fileName).toList(),
      'files': multipartFiles, // Dio handles lists of MultipartFiles automatically
      'signature': (signature != null)
          ? MultipartFile.fromBytes(
        signature,
        filename: "signature.png",
        contentType: DioMediaType.parse("image/png"),
      )
          : null,
    });

    // 3. Send the formData object
    return dio.put(
      '/api/leave_request/resend',
      data: formData,
    );
  }

  Future<Response<dynamic>> getLeaveInfo(LeaveType leaveType) {
    return dio.get(
      '/api/leave_request/leave_info',
      queryParameters: {
        'leave-type': leaveType.name,
      },
    );
  }
}


