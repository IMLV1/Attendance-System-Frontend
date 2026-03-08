import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class PersonnelAttendanceService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> fetchHistory({
    required String personnelId,
    String? startDate,
    String? endDate,
  }) {
    return dio.get(
      '/manager/personnel_info/attendance/history',
      queryParameters: {
        'id': personnelId,
        'startDate': ?startDate,
        'endDate': ?endDate,
      },
    );
  }

  Future<Response<dynamic>> getFilterRange({required String personnelId}) {
    return dio.get(
      '/manager/personnel_info/attendance/filter_range',
      queryParameters: {
        'id': personnelId,
      }
    );
  }
}