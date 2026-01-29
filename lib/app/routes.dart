import 'package:attendance_system/features/checkin/checkin_page.dart';
import 'package:attendance_system/features/leave/leave_page.dart';
import 'package:attendance_system/features/profile/profile_page.dart';
import 'package:attendance_system/features/settings/attendance/setting_attendance.dart';
import 'package:attendance_system/features/settings/attendance_request/setting_attendance_request.dart';
import 'package:attendance_system/features/settings/budget_year/setting_budget_year.dart';
import 'package:attendance_system/features/settings/leave_type/setting_leave_type.dart';
import 'package:attendance_system/features/settings/setting_page.dart';
import 'package:attendance_system/features/statistic/statistic_page.dart';
import 'package:attendance_system/features/time_request/time_request_page.dart';
import 'package:attendance_system/shared/widgets/base_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/auth/login_page.dart';
import '../service_locator.dart';

final appRouter = GoRouter(
  refreshListenable: getIt<AuthState>(),
  initialLocation: '/login',
  // redirect: (_, state) {
  //
  //   final location = state.matchedLocation;
  //
  //   if (location == '/') return 'login';
  //   return null;
  //
  //   // final auth = getIt<AuthState>();
  //   // final location = state.matchedLocation;
  //   //
  //   // // if (auth.status == AuthStatus.unknown) {
  //   // //   return location == '/splash' ? null : '/splash';
  //   // // }
  //   //
  //   // if (!auth.isLoggedIn) {
  //   //   return location == '/login' ? null : '/login';
  //   // }
  //   //
  //   // if (auth.isLoggedIn && (location == '/login' || location == '/splash')) {
  //   //   return '/home';
  //   // }
  //   //
  //   // return null;
  // },

  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const Center(child: CircularProgressIndicator()),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return BaseView(child: child);
      },
      routes: [
        GoRoute(
          path: '/check-in',
          pageBuilder: (_, __) => const NoTransitionPage(child: CheckinPage()),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingPage(),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, __) => const NoTransitionPage(child: ProfilePage()),
        ),
        GoRoute(
          path: '/statistic',
          pageBuilder: (_, __) => const NoTransitionPage(child: StatisticPage()),
        ),
        GoRoute(
          path: '/time-request',
          pageBuilder: (_, __) => const NoTransitionPage(child: TimeRequestPage()),
        ),
        GoRoute(
          path: '/leave',
          pageBuilder: (_, __) => const NoTransitionPage(child: LeaveRequestPage()),
        ),
        GoRoute(
          path: '/settings/budget-year',
          builder: (_, __) => const SettingBudgetYear(),
        ),
        GoRoute(
          path: '/settings/config-attendance',
          builder: (_, __) => const SettingAttendance(),
        ),
        GoRoute(
          path: '/settings/config-attendance-request',
          builder: (_, __) => const SettingAttendanceRequest(),
        ),
        GoRoute(
          path: '/settings/config-leave-type',
          builder: (_, __) => const SettingLeaveType(),
        ),
      ],
    ),
  ],

  // routes: [
  //   GoRoute(
  //     path: '/splash',
  //     builder: (_, __) => const Scaffold(
  //       body: Center(child: CircularProgressIndicator()),
  //     ),
  //   ),
  //   GoRoute(
  //       path: '/login',
  //       builder: (_, __) => MaterialApp(
  //         debugShowCheckedModeBanner: false,
  //         theme: AppTheme.lightTheme,
  //         home: LoginPage(),
  //       )
  //   ),
  //   GoRoute(
  //    path: '/profile',//Profile Page
  //     builder: (_, __) => MaterialApp(
  //       theme: AppTheme.lightTheme,
  //       home: ProfilePage(),
  //     )
  //   ),
  // ],
);