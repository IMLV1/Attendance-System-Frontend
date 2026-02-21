import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/core/data/entities/profile_model.dart';
import 'package:attendance_system/core/data/repositories/profile_repository.dart';
import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthState authState;
  final ProfileRepository repository;

  ProfileProvider(this.authState, this.repository) {
    authState.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    if (authState.status == AuthStatus.authenticated) {
      load(forceRefresh: true);
    } else {
      clear();
    }
  }

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
    notifyListeners();
  }

  @override
  void dispose() {
    authState.removeListener(_onAuthChanged);
    super.dispose();
  }
}