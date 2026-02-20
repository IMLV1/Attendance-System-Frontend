import 'package:attendance_system/core/data/entities/profile_model.dart';
import 'package:attendance_system/core/data/repositories/profile_repository.dart';
import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileProvider(this.repository);

  ProfileModel? profile;
  bool isLoading = false;

  Future<void> load({bool forceRefresh = false}) async {
    isLoading = true;
    notifyListeners();

    profile = await repository.getProfile(forceRefresh: forceRefresh);

    isLoading = false;
    notifyListeners();
  }

  void clear() {
    profile = null;
  }
}