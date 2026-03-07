import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class PersonnelInfoService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getPersonnelList() async {
    return dio.get('/manager/personnel_info/users');
  }

  Future<Response<dynamic>> getPermissionLevel(String personnelID) async {
    return dio.get(
      '/manager/personnel_info/permissions',
      queryParameters: {
        'id': personnelID,
      },
    );
  }
}