import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class PersonnelStatisticService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getStatistic({required String personnelId, required DateTime year}) {
    return dio.get(
      '/manager/personnel_info/statistic',
      queryParameters: {
        'id': personnelId,
        'year': year.year,
      },
    );
  }

  Future<Response<dynamic>> getWorkingHour({required String personnelId}) {
    return dio.get(
      '/manager/personnel_info/statistic/working_hours',
      queryParameters: {
        'id': personnelId,
      }
    );
  }

  Future<Response<dynamic>> getFilterRange({required String personnelId}) {
    return dio.get(
      '/manager/personnel_info/statistic/filter_range',
      queryParameters: {
        'id': personnelId,
      }
    );
  }
}