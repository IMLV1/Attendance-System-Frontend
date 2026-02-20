import 'package:attendance_system/core/data/api/api.dart';
import 'package:dio/dio.dart';

class ConfigBudgetYearApi extends Api {

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
