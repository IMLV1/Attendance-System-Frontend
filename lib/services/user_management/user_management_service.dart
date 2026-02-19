import 'package:attendance_system/services/max_leave/max_leave_model.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

class UserManagementService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getData() {
    return dio.get('/system/user_management/users');
  }

  Future<Response<dynamic>> createUser(UserManagementModel userInfo, MaxLeaveModel maxLeave) {

    // print('UserInfo: $userInfo');
    // print('MaxLeave: $maxLeave');

    Future<Response<dynamic>> response = dio.post('/system/user_management/create',
      data: {
        'id': userInfo.id,
        'email': userInfo.email,
        'user-info': {
          'name-th': userInfo.nameTH,
          'name-en': userInfo.nameEN,
          'employee-id': userInfo.employeeId,
          'gender': userInfo.gender,
          'nationality': userInfo.nationality,
          'phone': userInfo.phone,
          'initial-role': userInfo.initRole,
        },
        'max-leave': {
          'sick': maxLeave.sick,
          'personal': maxLeave.personal,
          'vacation': maxLeave.vacation,
          'maternity': maxLeave.maternity,
          'paternity': maxLeave.paternity,
          'parental': maxLeave.parental
        }
      },
    );

    // response.then((res) => print(res.data));
    return response;
  }

  Future<Response<dynamic>> updateUserInfo(UserManagementModel userInfo) {

    return dio.put(
      '/system/user_management/update/${userInfo.id}',
      data: {
        'name-th': userInfo.nameTH,
        'name-en': userInfo.nameEN,
        'employee-id': userInfo.employeeId,
        'gender': userInfo.gender,
        'nationality': userInfo.nationality,
        'phone': userInfo.phone,
        'initial-role': userInfo.initRole,
      },
    );
  }

  Future<Response<dynamic>> updateRole(String id, List<Role> roles) {
    return dio.put(
      '/system/user_management/update_role/$id',
      data: {
        'roles': roles.map((m) => m.id).toList()
      },
    );
  }

  Future<Response<dynamic>> deleteUser(String id) {

    Future<Response<dynamic>> response = dio.delete(
      '/system/user_management/delete',
      data: {
        'id': id
      }
    );

    return response;
  }
}
