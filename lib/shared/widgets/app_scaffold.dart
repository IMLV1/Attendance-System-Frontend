import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/navigation/bottom_navigation.dart';
import 'package:attendance_system/shared/widgets/navigation/navigation_state.dart';
import 'package:attendance_system/shared/widgets/navigation/sidebar_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatelessWidget {

  final Widget content;
  final Header? header;
  final bool hideNavigation;

  const AppScaffold({super.key, this.hideNavigation = false, required this.content, this.header});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationState(),
      child: Scaffold(
        body: Row(
          children: [

            if (Responsive.isDesktop(context) && !hideNavigation) SideBarNavigation(),

            Expanded(
              flex: 3,
              child: Scaffold(
                body: Stack(
                children: [
                  content,
                  ?header,
                ],
              ),
              bottomNavigationBar: (!hideNavigation) ? BottomNavigation() : null,
              )
            ),
          ],
        )
      )
    );
  }
}