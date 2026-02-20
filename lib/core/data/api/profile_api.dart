import 'package:attendance_system/core/data/api/api.dart';
import 'package:dio/dio.dart';

class ProfileApi extends Api {

  @override
  Future<Response<dynamic>> call() {
    return dio.get('/profile/me');
  }
}
