import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'role_management_model.dart';

class RoleManagementService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getRoleManagementModel() async {
    return dio.get('/system/role');
  }

  Future<Response<dynamic>> getAllUser(RoleSystem e) async {
    return dio.get('/system/role/all-user/${e.id}');
  }

  Future<Response<dynamic>> updateRole(RoleSystem element) async {
    return dio.put(
      '/system/role/update/${element.id}',
      data: {
        'id': element.id,
        'type': roleTypeToApi(element.type),
        'color': element.roleColor,
        'name': element.roleName,
        'members': element.members.map((e) => {
          'id': e.id,
        }).toList(),
      },
    );
  }

  Future<Response<dynamic>> deleteRole(RoleSystem element) {

    Future<Response<dynamic>> response = dio.delete(
        '/system/role/delete',
        data: {
          'id': element.id
        }
    );

    return response;
  }
}
