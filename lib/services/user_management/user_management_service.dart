import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

class ProfileService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<List<UserManagementModel>> getProfile() async {
    final res = await dio.get('/system/user_management/users');
    return UserManagementModel.getList(res.data);
  }
}
