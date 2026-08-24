import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/widgets/navigation/bottom_navigation.dart';
import 'package:attendance_system/shared/widgets/navigation/sidebar_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseView extends StatelessWidget {

  final Widget child;

  const BaseView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {

    final location = GoRouterState.of(context).fullPath;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [

          if (Responsive.showSidebar(context)) SideBarNavigation(currentPath: location ?? ''),

          Expanded(
            flex: 3,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: child,
              // 🚩 (2026-08-23) เดิมเช็ค isMobile (< 600) -> ช่วง "tablet" (600–1200)
              // ไม่ได้ทั้ง sidebar (ขึ้นเฉพาะ >= 1200) และไม่ได้ทั้ง bottom nav
              // = ไม่มีเมนูให้กดเลย ซึ่งครอบคลุม iPad แทบทุกรุ่น
              // (2026-08-24) ตอนนี้ผูกกับตัวเดียวกับ sidebar: มีอย่างใดอย่างหนึ่งเสมอ
              bottomNavigationBar: Responsive.showSidebar(context) ? null : BottomNavigation(currentPath: location ?? ''),
            )
          ),
        ],
      )
    );
  }
}