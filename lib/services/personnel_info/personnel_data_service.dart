import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class PersonnelDataService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getData(String personnelID) {
    return dio.get(
      '/api/personnel_info/personnel_data',
      queryParameters: {
        'id': personnelID,
      },
    );
  }

}