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

          if (Responsive.isDesktop(context)) SideBarNavigation(currentPath: location ?? ''),

          Expanded(
            flex: 3,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: child,
              bottomNavigationBar: (Responsive.isMobile(context)) ? BottomNavigation(currentPath: location ?? '') : null,
            )
          ),
        ],
      )
    );
  }
}