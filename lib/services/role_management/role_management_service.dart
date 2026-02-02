import 'package:attendance_system/services/role_management/role_management_model.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

class RoleManagementService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<RoleManagementModel> getRoleManagementModel() async {
    final res = await dio.get('system/role');
    return RoleManagementModel.fromJson(res.data);
  }
}