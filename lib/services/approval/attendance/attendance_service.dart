import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';

class AttendanceApprovalService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getPending() async {
    return dio.get('api/attendance-approval/pending');
  }

  Future<Response<dynamic>> getRecent() async {
    return dio.get('api/attendance-approval/recent');
  }

  Future<Response<dynamic>> getDetail(String id) async {
    return dio.get('api/attendance-approval/detail',
      queryParameters: {
        'request-id': id
      }
    );
  }
}