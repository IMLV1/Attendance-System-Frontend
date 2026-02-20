import 'package:attendance_system/core/data/api/profile_api.dart';
import 'package:attendance_system/core/data/api_handler.dart';
import 'package:attendance_system/core/data/entities/profile_model.dart';

class ProfileRepository {

  ProfileModel? _cache;

  Future<ProfileModel?> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      return _cache!;
    }

    await ApiHandler(
      request: () => ProfileApi().call(),
      onError: (error) {

      },
      onSuccess: (data) {
        ProfileModel model = ProfileModel.fromJson(data);
        _cache = model;
      }
    ).call();

    return _cache;
  }
}