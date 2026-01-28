import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/sub_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingBudgetYear extends StatelessWidget {
  const SettingBudgetYear({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        header: SubHeader(title: 'ตั้งค่าปีงบประมาณ'),
        content: MaterialApp()
    );
  }

}