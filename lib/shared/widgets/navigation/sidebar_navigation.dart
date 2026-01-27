import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SideBarNavigation extends StatelessWidget {
  const SideBarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: Scaffold(
          backgroundColor: AppColors.sideBarColor,
          appBar: AppBar(
            elevation: 0,

            toolbarHeight: 65,
            automaticallyImplyLeading: false,

            leadingWidth: double.infinity,

            leading: Image.asset(
              'assets/images/engineering_logo.png',
              width: double.infinity,
              fit: BoxFit.contain,
            )
          ),
          body: Column(
            children: [
              Text('Hello World'),
              Text('Hello World'),
              Text('Hello World'),
              Text('Hello World'),
            ],
          )
      )
    );
  }

}