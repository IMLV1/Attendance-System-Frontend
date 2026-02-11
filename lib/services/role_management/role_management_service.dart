import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'role_management_model.dart';

class RoleManagementService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<RoleManagementModel> getRoleManagementModel() async {
    final res = await dio.get('system/role');
    return RoleManagementModel.fromJson(res.data);
  }

  /// update role name + color
  Future<void> updateRole({required String roleId, required String name, required String color,}) async {
    await dio.put(
      'system/role/$roleId',
      data: {
        'roleName': name,
        'roleColor': color,
      },
    );
  }

  /// delete member from role
  Future<void> deleteMember({required String roleId, required String memberId,}) async {
    await dio.delete('system/role/$roleId/member/$memberId');
  }

  Future<void> deleteRole({required String roleId,}) async {
    await dio.delete(
      'system/role/$roleId',
    );
  }

  /// update role type (main / special / admin / hr)
  Future<void> updateRoletype({required String roleType, required roleId}) async {
    await dio.put(
      'system/role/$roleId/type',
      data: {
        'type' : roleType
      },
    );
  }
}
