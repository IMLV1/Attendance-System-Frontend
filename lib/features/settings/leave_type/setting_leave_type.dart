import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';

class SettingLeaveType extends StatelessWidget {
  const SettingLeaveType({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return AppScaffold(
        header: Header.subHeader(context,
            title: 'การตั้งค่าและการจัดการ'
        ),
        content: MaterialApp()
    );
  }

}