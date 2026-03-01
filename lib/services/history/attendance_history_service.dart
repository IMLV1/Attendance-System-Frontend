import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class AttendanceHistoryService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> fetchHistory({
    String? startDate,
    String? endDate,
  }) {
    return dio.get(
      '/api/attendance/history',
      queryParameters: {
        'startDate': ?startDate,
        'endDate': ?endDate,
      },
    );
  }
}