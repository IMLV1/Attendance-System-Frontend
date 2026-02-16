import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'role_management_model.dart';
import 'package:uuid/uuid.dart';

class RoleManagementService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getRoleManagementModel() async {
    return dio.get('/system/role_management/role');
  }

  Future<Response<dynamic>> getUser(RoleSystem e) async {
    return dio.get('/system/role_management/all-user/${e.id}');
  }

  Future<Response<dynamic>> getAllUser() async {
    return dio.get('/system/role/create/all-user');
  }

  Future<Response<dynamic>> updateRole(RoleSystem element) async {
    return dio.put(
      '/system/role_management/update/${element.id}',
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

  Future<Response<dynamic>> createRole(RoleSystem element) async {
    final uuid = Uuid();
    final newId = uuid.v4();

    print(newId);
    return dio.post(
      '/system/role/create',
      data: {
        'id': newId,
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
        '/system/role_management/delete',
        data: {
          'id': element.id
        }
    );

    return response;
  }
}
