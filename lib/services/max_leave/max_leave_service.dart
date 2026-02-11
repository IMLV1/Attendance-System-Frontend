import 'package:attendance_system/services/max_leave/max_leave_model.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

class MaxLeaveService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getData(String userId) async {
    return dio.get('/system/user_management/max_leaves/${userId}');
  }
}
