import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class PersonnelInfoService {

  final Dio dio = GetIt.I<ApiClient>().dio;
  Future<Response<dynamic>> getPersonnelList() async {
    return dio.get('api/personnel_info/users');
  }
}