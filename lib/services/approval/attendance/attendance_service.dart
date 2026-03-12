import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';

class AttendanceApprovalService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getPending() async {
    return dio.get('/api/attendance-approval/pending');
  }

  Future<Response<dynamic>> getRecent(DateTime? filterStartDate, DateTime? filterEndDate) async {
    return dio.get('/api/attendance-approval/recent',
      queryParameters: {
        if (filterStartDate != null)
          'startDate': filterStartDate.toIso8601String(),
        if (filterEndDate != null)
          'endDate': filterEndDate.toIso8601String(),
      },
    );
  }

  Future<Response<dynamic>> getFilterRange() async {
    return dio.get('/api/attendance-approval/filter_range');
  }

  Future<Response<dynamic>> getDetail(String id) async {
    return dio.get('/api/attendance-approval/detail',
      queryParameters: {
        'request-id': id
      }
    );
  }

  Future<Response<dynamic>> approval(String reqId, String status, String reason, Uint8List? signature) async {

    FormData formData = FormData.fromMap(
      {
        'status': status,
        'reason': reason,
        'signature-approval': signature != null ? MultipartFile.fromBytes(
          signature,
          filename: "signature.png",
          contentType: DioMediaType.parse("image/png"),
        ) : null
      }
    );

    final response = await dio.put('/api/attendance-approval/$reqId',
      data: formData,
    );

    return response;
  }
}