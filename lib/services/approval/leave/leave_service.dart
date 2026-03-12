import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';

class LeaveApprovalService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> pending() async {
    return dio.get('/api/leave-approval/pending');
  }

  Future<Response<dynamic>> recent(DateTime? filterStartDate, DateTime? filterEndDate) async {
    return dio.get('/api/leave-approval/recent',
      queryParameters: {
        if (filterStartDate != null)
          'startDate': filterStartDate.toIso8601String(),
        if (filterEndDate != null)
          'endDate': filterEndDate.toIso8601String(),
      },
    );
  }

  Future<Response<dynamic>> getFilterRange() async {
    return dio.get('/api/leave-approval/filter_range');
  }

  Future<Response<dynamic>> getUserDetail(String id) async {
    return dio.get('/api/leave-approval/user_detail',
        queryParameters: {
          'user-id': id
        }
    );
  }

  Future<Response<dynamic>> getRequestDetail(String id) async {
    return dio.get('/api/leave-approval/request_detail',
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

    final response = await dio.put('/api/leave-approval/$reqId',
      data: formData
    );

    return response;
  }
}