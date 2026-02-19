import 'package:attendance_system/core/auth/user_model.dart';
import 'package:attendance_system/services/profile_page/profile_model.dart';
import 'package:attendance_system/services/profile_page/profile_service.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_model.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_service.dart';
import 'package:attendance_system/services/system_config/attendance_request/config_attendance_request_model.dart';
import 'package:attendance_system/services/system_config/attendance_request/config_attendance_request_service.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_model.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends ChangeNotifier {
  final AuthRepository repo;

  AuthStatus status = AuthStatus.unknown;

  UserModel? user;
  ProfileModel? profile;
  ConfigLeaveModel? leaveConfig;
  ConfigAttendanceTimeModel? timeConfig;
  ConfigAttendanceRequestModel? attendanceConfig;

  AuthState(this.repo);

  bool get isLoggedIn => status == AuthStatus.authenticated;

  Future<void> init() async {
    final ok = await repo.hasToken();
    status = ok ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    if (status == AuthStatus.authenticated) {
      {
        Response response = await ProfileService().getProfile();
        if (response.statusCode == 200) {
          profile = ProfileModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigLeaveService().getData();
        if (response.statusCode == 200) {
          leaveConfig = ConfigLeaveModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigAttendanceRequestService().getData();
        if (response.statusCode == 200) {
          attendanceConfig = ConfigAttendanceRequestModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigAttendanceTimeService().getData();
        if (response.statusCode == 200) {
          timeConfig = ConfigAttendanceTimeModel.fromJson(response.data);
        }
      }
    }

    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    try {
      final result = await repo.loginWithGoogle();
      user = result.user;
      status = AuthStatus.authenticated;

      {
        Response response = await ProfileService().getProfile();
        if (response.statusCode == 200) {
          profile = ProfileModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigLeaveService().getData();
        if (response.statusCode == 200) {
          leaveConfig = ConfigLeaveModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigAttendanceTimeService().getData();
        if (response.statusCode == 200) {
          timeConfig = ConfigAttendanceTimeModel.fromJson(response.data);
        }
      }
      {
        Response response = await ConfigAttendanceRequestService().getData();
        if (response.statusCode == 200) {
          attendanceConfig = ConfigAttendanceRequestModel.fromJson(response.data);
        }
      }
    } catch (e) {
      status = AuthStatus.unauthenticated;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repo.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}