import 'package:attendance_system/features/settings/attendance/setting_attendance.dart';
import 'package:attendance_system/features/settings/attendance_request/setting_attendance_request.dart';
import 'package:attendance_system/features/settings/budget_year/setting_budget_year.dart';
import 'package:attendance_system/features/settings/leave_type/setting_leave_type.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/sub_header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingLeaveType extends StatelessWidget {
  const SettingLeaveType({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return AppScaffold(
        header: SubHeader(
            title: 'การตั้งค่าและการจัดการ'
        ),
        content: SafeArea(
            child: SingleChildScrollView(

                child: Container(
                    child: Column(
                        children: []
                    )
                )
            )
        )
    );
  }

}