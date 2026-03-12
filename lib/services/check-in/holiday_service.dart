import 'package:dio/dio.dart';

class HolidayService {
  final Dio dio;
  HolidayService(this.dio);

  Future<Response<dynamic>> getPublicHolidays(String year) {
    return dio.get(
      '/api/attendance/today',
      queryParameters: {
        'year': year.toString(),
      },
    );
  }
}