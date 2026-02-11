import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

class UserManagementService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getData() {
    return dio.get('/system/user_management/users');
  }
}
