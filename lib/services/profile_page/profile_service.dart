import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'profile_model.dart';

class ProfileService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<ProfileModel> getProfile() async {
    final res = await dio.get('/profile/me');
    return ProfileModel.fromJson(res.data);
  }
}
