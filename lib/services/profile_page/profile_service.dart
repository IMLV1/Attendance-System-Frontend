import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

class ProfileService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getProfile() async {
    return dio.get('/profile/me');
  }
}
