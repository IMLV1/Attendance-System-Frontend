import 'package:attendance_system/features/main_feature/checkin_page.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_request_page.dart';
import 'package:attendance_system/features/main_feature/profile_page.dart';
import 'package:attendance_system/features/main_feature/statistic_page.dart';
import 'package:attendance_system/features/main_feature/time_request_page.dart';
import 'package:attendance_system/features/settings/admin_config/setting_attendance.dart';
import 'package:attendance_system/features/settings/admin_config/setting_attendance_request.dart';
import 'package:attendance_system/features/settings/admin_config/setting_budget_year.dart';
import 'package:attendance_system/features/settings/admin_config/setting_leave_type.dart';
import 'package:attendance_system/features/settings/setting_page.dart';
import 'package:attendance_system/features/settings/user_management/user/user_management.dart';
import 'package:attendance_system/shared/widgets/base_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/auth/login_page.dart';
import '../features/history/attendance_history.dart';
import '../features/settings/role_management/role_management.dart';
import '../service_locator.dart';

final appRouter = GoRouter(
  refreshListenable: getIt<AuthState>(),
  initialLocation: '/login',
  redirect: (_, state) {
    final auth = getIt<AuthState>();
    final location = state.matchedLocation;

    if (auth.status == AuthStatus.unknown) {
      return location == '/splash' ? null : '/splash';
    }

    final isLogin = location == '/login';

    if (auth.status == AuthStatus.unauthenticated) {
      return isLogin ? null : '/login';
    }

    if (auth.status == AuthStatus.authenticated && isLogin) {
      return '/check-in';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, _) => const Center(child: CircularProgressIndicator()),
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return BaseView(child: child);
      },
      routes: [
        GoRoute(
          path: '/check-in',
          pageBuilder: (_, _) => const NoTransitionPage(child: CheckinPage()),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, _) => const SettingPage(),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, _) => const NoTransitionPage(child: ProfilePage()),
        ),
        GoRoute(
          path: '/statistic',
          pageBuilder: (_, _) => const NoTransitionPage(child: StatisticPage()),
        ),
        GoRoute(
          path: '/time-request',
          pageBuilder: (_, _) => const NoTransitionPage(child: TimeRequestPage()),
        ),
        GoRoute(
          path: '/leave',
          pageBuilder: (_, _) => const NoTransitionPage(child: LeaveRequestPage()),
        ),
        GoRoute(
          path: '/settings/budget-year',
          builder: (_, _) => const SettingBudgetYear(),
        ),
        GoRoute(
          path: '/settings/config-attendance',
          builder: (_, _) => const SettingAttendance(),
        ),
        GoRoute(
          path: '/settings/config-attendance-request',
          builder: (_, _) => const SettingAttendanceRequest(),
        ),
        GoRoute(
          path: '/settings/config-leave-type',
          builder: (_, _) => const SettingLeaveType(),
        ),
        GoRoute(
          path: '/settings/user-management',
          builder: (_, _) => const UserManagement(),
        ),
        GoRoute(
          path: '/settings/role-management',
          builder: (_, _) => const RoleManagement(),
        ),
        GoRoute(
            path: '/history/attendance',
            builder: (_, _) => const AttendanceHistory(),
        )
      ],
    ),
  ],
);