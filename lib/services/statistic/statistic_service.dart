import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class StatisticService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getStatistic({required DateTime year}) {
    return dio.get(
      '/user/statistic',
      queryParameters: {
        'year': year
      },
    );
  }

  Future<Response<dynamic>> getWorkingHour() {
    return dio.get('/user/statistic/working_hours');
  }

  Future<Response<dynamic>> getFilterRange() {
    return dio.get('/user/statistic/filter_range');
  }
}