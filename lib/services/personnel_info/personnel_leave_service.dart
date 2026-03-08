import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class PersonnelLeaveService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getPending(String personnelID) {
    return dio.get(
      '/manager/personnel_info/leave/pending',
      queryParameters: {
        'id': personnelID,
      },
    );
  }
  Future<Response<dynamic>> getRecent(String personnelID, DateTime? filterStartDate, DateTime? filterEndDate,) {
    return dio.get(
      '/manager/personnel_info/leave/recent',
      queryParameters: {
        'id': personnelID,
        if (filterStartDate != null)
          'startDate': filterStartDate.toIso8601String(),
        if (filterEndDate != null)
          'endDate': filterEndDate.toIso8601String(),
      },
    );
  }
  Future<Response<dynamic>> getFilterRange(String personnelID) {
    return dio.get(
      '/manager/personnel_info/leave/filter_range',
      queryParameters: {
        'id': personnelID,
      },
    );
  }
  Future<Response<dynamic>> getRequestDetail(String requestId) {
    return dio.get(
      '/manager/personnel_info/leave/detail',
      queryParameters: {
        'request-id': requestId,
      },
    );
  }
}