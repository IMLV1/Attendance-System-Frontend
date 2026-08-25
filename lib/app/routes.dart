import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/features/main_feature/checkin_page.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_request_create.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_request_status.dart';
import 'package:attendance_system/features/main_feature/profile_page.dart';
import 'package:attendance_system/features/main_feature/statistic/statistic_page.dart';
import 'package:attendance_system/features/main_feature/time_request/time_request_create.dart';
import 'package:attendance_system/features/main_feature/time_request/time_request_page.dart';
import 'package:attendance_system/features/settings/admin_config/setting_attendance.dart';
import 'package:attendance_system/features/settings/admin_config/setting_attendance_request.dart';
import 'package:attendance_system/features/settings/admin_config/setting_budget_year.dart';
import 'package:attendance_system/features/settings/admin_config/setting_leave_type.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_info.dart';
import 'package:attendance_system/features/settings/setting_page.dart';
import 'package:attendance_system/features/settings/user_management/user/user_management.dart';
import 'package:attendance_system/shared/widgets/base_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../core/utils/responsive.dart';
import '../features/auth/login_page.dart';
import '../features/history/attendance_history.dart';
import '../features/notification/notification.dart';
import '../features/settings/approval/approval.dart';
import '../features/settings/role_management/role_management.dart';
import '../service_locator.dart';

/// ปลายทางที่ผู้ใช้ขอมาตอนเปิดแอป ก่อนโดนพักไว้ที่ /splash เพื่อรอ auth
///
/// 🚩 (2026-08-25) เดิมไม่ได้จำไว้ พอ auth เช็คเสร็จก็โยนเข้า /check-in ทุกครั้ง
/// บน web แปลว่ากด F5 ค้างอยู่หน้าไหนก็เด้งกลับหน้าเช็คอินหมด และลิงก์ตรงไป
/// หน้าใดหน้าหนึ่งใช้ไม่ได้เลย
String? _pendingLocation;

/// หน้าที่เป็นแค่ทางผ่าน ไม่ควรถูกจำเป็นปลายทาง
const _transientLocations = {'/splash', '/login'};

/// หน้าที่เป็น **ปลายทางของ sidebar บนจอกว้าง** แต่เป็น **หน้าที่ push มา**
/// บนจอแคบ
///
/// 🚩 (2026-08-25) สี่หน้านี้ (/attendance-history, /approval, /personnel-info,
/// /settings) เดิมอยู่ในเมนู "การตั้งค่าและการจัดการ" แล้วถูกยกขึ้นมาเป็นปลายทาง
/// ของ sidebar ตอน Phase 1 แต่ยังใช้ `builder:` เฉยๆ อยู่ ซึ่ง go_router จะห่อ
/// ด้วย MaterialPage ให้ = มีอนิเมชันเลื่อนเข้าแบบ push
///
/// ผลคือกดสลับเมนูใน sidebar แล้วสี่หน้านี้เลื่อนเข้ามา ต่างจากอีกห้าหน้าที่
/// สลับทันที (ใช้ NoTransitionPage) — รู้สึกเหมือนกดเข้าไป "ข้างใน" ไม่ใช่สลับ
/// ปลายทาง
///
/// แก้ไม่ได้ด้วยการเปลี่ยนเป็น NoTransitionPage เฉยๆ เพราะบนจอแคบสี่หน้านี้
/// ถูก `pushNamed` มาจริงๆ (จากเมนูการตั้งค่า / ปุ่ม ≡) อนิเมชันเลื่อนถูกต้องแล้ว
///
/// จึงคงชนิด Page ไว้ตัวเดียวเสมอ แล้วไปตัดสินที่ `transitionsBuilder` แทน —
/// ถ้าเปลี่ยนชนิด Page ตามขนาดจอ พอผู้ใช้หมุน iPad ระหว่างอยู่หน้านั้น
/// `Page.canUpdate` จะเป็น false (คนละ runtimeType) Navigator จะถอดหน้าเก่าทิ้ง
/// แล้ว push ใหม่ = state ของหน้าหายทั้งก้อน
CustomTransitionPage<void> _destinationPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // จอที่มี sidebar = สลับปลายทาง ไม่ใช่กดเข้าไปข้างใน จึงไม่ต้องมีอนิเมชัน
      if (Responsive.showSidebar(context)) return child;

      return SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.fastOutSlowIn)),
        ),
        child: child,
      );
    },
  );
}

final appRouter = GoRouter(
  refreshListenable: getIt<AuthState>(),
  initialLocation: '/login',
  redirect: (_, state) {
    final auth = getIt<AuthState>();
    final location = state.matchedLocation;

    if (auth.status == AuthStatus.unknown) {
      if (location == '/splash') return null;
      // ใช้ uri ไม่ใช่ matchedLocation จะได้เก็บ query string ติดไปด้วย
      if (!_transientLocations.contains(location)) {
        _pendingLocation = state.uri.toString();
      }
      return '/splash';
    }

    if (auth.status == AuthStatus.unauthenticated) {
      if (location == '/login') return null;
      if (!_transientLocations.contains(location)) {
        _pendingLocation = state.uri.toString();
      }
      return '/login';
    }

    // authenticated — ถ้ายังค้างอยู่ที่หน้าทางผ่าน ให้พากลับไปที่ที่ขอไว้
    if (_transientLocations.contains(location)) {
      final pending = _pendingLocation;
      _pendingLocation = null;
      return pending ?? '/check-in';
    }

    return null;
  },

  routes: [
    GoRoute(
      name: '1',
      path: '/splash',
      builder: (_, _) => const Center(child: CircularProgressIndicator()),
    ),
    GoRoute(
      name: RouteNames.login,
      path: '/login',
      builder: (_, _) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return BaseView(child: child);
      },
      routes: [
        GoRoute(
          name: RouteNames.checkin,
          path: '/check-in',
          pageBuilder: (_, _) => const NoTransitionPage(child: CheckinPage()),
        ),
        GoRoute(
          name: RouteNames.notification,
          path: '/notification',
          builder: (_, _) => const NotificationPage(),
        ),
        GoRoute(
          name: RouteNames.setting,
          path: '/settings',
          pageBuilder: (_, state) =>
              _destinationPage(state, const SettingPage()),
          routes: [
            GoRoute(
              name: RouteNames.settingBudgetYear,
              path: 'budget-year',
              builder: (_, _) => const SettingBudgetYear(),
            ),
            GoRoute(
              name: RouteNames.settingAttendanceTime,
              path: 'config-attendance',
              builder: (_, _) => const SettingAttendance(),
            ),
            GoRoute(
              name: RouteNames.settingAttendanceRequest,
              path: 'config-attendance-request',
              builder: (_, _) => const SettingAttendanceRequest(),
            ),
            GoRoute(
              name: RouteNames.settingLeaveType,
              path: 'config-leave-type',
              builder: (_, _) => const SettingLeaveType(),
            ),
            GoRoute(
              name: RouteNames.userManagement,
              path: 'user-management',
              builder: (_, _) => const UserManagement(),
            ),
            GoRoute(
              name: RouteNames.roleManagement,
              path: 'role-management',
              builder: (_, _) => const RoleManagement(),
            ),
          ]
        ),

        // 🚩 (2026-08-24) 3 หน้านี้ย้ายออกมาเป็น route ระดับบนสุด — เดิมเป็นลูกของ
        // `/settings` ทำให้ `context.go()` จาก sidebar สร้างสแตกที่มี `/settings`
        // คาอยู่ข้างล่าง พฤติกรรมจึงไม่เหมือนหน้าหลักอื่นทั้งที่อยู่ในเมนูข้างเหมือนกัน
        // (หน้าตั้งค่ายังเข้าถึงได้เหมือนเดิมเพราะนำทางด้วย `pushNamed` ไม่ใช่ path)
        GoRoute(
          name: RouteNames.approval,
          path: '/approval',
          pageBuilder: (context, state) {
            final initialTab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
            return _destinationPage(state, Approval(initialTab: initialTab));
          },
        ),
        GoRoute(
          name: RouteNames.attendanceHistory,
          path: '/attendance-history',
          pageBuilder: (_, state) =>
              _destinationPage(state, const AttendanceHistory()),
        ),
        GoRoute(
          name: RouteNames.personnelInfo,
          path: '/personnel-info',
          pageBuilder: (_, state) =>
              _destinationPage(state, const PersonnelInfo()),
        ),
        GoRoute(
          name: RouteNames.profile,
          path: '/profile',
          pageBuilder: (_, _) => const NoTransitionPage(child: ProfilePage()),
        ),
        GoRoute(
          name: RouteNames.statistic,
          path: '/statistic',
          pageBuilder: (_, _) => const NoTransitionPage(child: StatisticPage()),
        ),
        GoRoute(
          name: RouteNames.attendanceRequest,
          path: '/attendance-request',
          pageBuilder: (_, _) => const NoTransitionPage(child: TimeRequestPage()),
          routes: [
            GoRoute(
              name: RouteNames.timeRequestCreate,
              path: 'create',
              builder: (_, _) => const TimeRequestCreate(),
            ),
          ]
        ),
        GoRoute(
          name: RouteNames.leaveRequest,
          path: '/leave-request',
          pageBuilder: (_, _) => const NoTransitionPage(child: LeaveRequestStatus()),
          routes: [
            GoRoute(
              name: RouteNames.attendanceRequestCreate,
              path: 'create',
              builder: (_, _) => const LeaveRequestCreate(),
            ),
          ]
        ),

      ],
    ),
  ],
);