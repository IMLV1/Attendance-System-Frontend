import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/navigation/bottom_navigation.dart';
import 'package:attendance_system/shared/widgets/navigation/sidebar_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {

  final Widget content;
  final Header? header;
  final bool hideNavigation;

  const AppScaffold({super.key, this.hideNavigation = false, required this.content, this.header});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (Responsive.isDesktop(context)) SideBarNavigation(),

          Expanded(
            flex: 3,
            child: Stack(
              children: [
                content,
                ?header,
                if (!hideNavigation) BottomNavigation()
              ],
            )
          )
        ],
      )
    );
  }

}