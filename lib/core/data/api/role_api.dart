import 'package:attendance_system/core/data/api/api.dart';
import 'package:dio/dio.dart';

class RoleApi extends Api {

  Future<Response<dynamic>> getData() async {
    return dio.get('/system/user_management/roles');
  }
}
