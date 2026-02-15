import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class ConfigBudgetYearService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getData() async {
    return dio.get('/system/config/budget_year/get');
  }

  Future<Response<dynamic>> update(int day, int month) async {
    return dio.put(
      '/system/config/budget_year/update',
      data: {
        'day': day,
        'month': month
      }
    );
  }
}
