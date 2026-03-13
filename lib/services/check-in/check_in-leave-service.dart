import 'package:dio/dio.dart';

class Leaveservice {
  final Dio dio;
  Leaveservice(this.dio);

  Future<Response<dynamic>> getLeave(String year) {
    return dio.get(
      '/api/attendance/leave',
      queryParameters: {
        'year': year.toString(),
      },
    );
  }
}