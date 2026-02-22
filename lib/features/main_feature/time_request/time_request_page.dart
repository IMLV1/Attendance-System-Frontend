import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/features/main_feature/time_request/time_request_create.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TimeRequestPage extends StatefulWidget{
  const TimeRequestPage({super.key});

  @override
  State<TimeRequestPage> createState() {
    return _TimeRequestPageState();
  }
}

class _TimeRequestPageState extends State<TimeRequestPage> {
  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      header: Header.mainHeader(
        context,
        title: 'ขออนุมัติเวลาเข้า-ออกงาน',
        subTitle: 'Attendance Request',
        iconPath: 'icon_time_request.svg',
        iconColor: Colors.white
      ),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      spacing: 13,
                      children: [
                        SeparatorCard(
                          children: [
                            IconTextButton(
                              icon: 'icon_create_role.svg',
                              label: 'สร้างคำขอใหม่',
                              color: Color(0xFF4986FF),
                              arrow: false,
                              onPressed: () {
                               context.pushNamed(RouteNames.timeRequestCreate);
                              },
                            )
                          ],
                        ),
                      ],
                    )
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
  
}
