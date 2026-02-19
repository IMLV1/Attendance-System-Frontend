import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

class RoleService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getData() async {
    return dio.get('/system/user_management/roles');
  }
}
