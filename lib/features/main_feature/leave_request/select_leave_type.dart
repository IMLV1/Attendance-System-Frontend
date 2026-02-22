import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_model.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class LeaveType extends StatelessWidget {
  const LeaveType({super.key});

  @override
  Widget build(BuildContext context) {

    ConfigLeaveModel? config = context.watch<AuthState>().leaveConfig;

    return AppScaffold(
        header: Header.subHeader(
            context,
            title: 'เลือกประเภทการลา'
        ),
        content: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.all(15),
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SeparatorCard(
                    separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 15),
                    children: [
                      AppButton(
                        icon: 'icon_sick.svg',
                        title: 'ลาป่วย',
                        weightTitle: FontWeight.w500,
                        onPressed: () {
                          Navigator.pop(context, ('ลาป่วย', config!.sick));
                        },
                      ),
                      AppButton(
                        icon: 'icon_leave_personal.svg',
                        title: 'ลากิจส่วนตัว',
                        weightTitle: FontWeight.w500,
                        onPressed: () {
                          Navigator.pop(context, ('ลากิจส่วนตัว', config!.personal));
                        },
                      ),
                      AppButton(
                        icon: 'icon_vacation.svg',
                        title: 'ลาพักผ่อน',
                        weightTitle: FontWeight.w500,
                        onPressed: () {
                          Navigator.pop(context, ('ลาพักผ่อน', config!.vacation));
                        },
                      ),
                      AppButton(
                        icon: 'icon_maternity_leave.svg',
                        title: 'ลาคลอดบุตร',
                        weightTitle: FontWeight.w500,
                        onPressed: () {
                          Navigator.pop(context, ('ลาคลอดบุตร', config!.maternity));
                        },
                      ),
                      AppButton(
                        icon: 'icon_leave_assist_childbirth.svg',
                        title: 'ลาช่วยเหลือภริยาคลอดบุตร',
                        weightTitle: FontWeight.w500,
                        onPressed: () {
                          Navigator.pop(context, ('ลาช่วยเหลือภริยาคลอดบุตร', config!.paternity));
                        },
                      ),
                      AppButton(
                        icon: 'icon_taking_care_child.svg',
                        title: 'ลากิจเพื่อเลี้ยงดูบุตร',
                        weightTitle: FontWeight.w500,
                        onPressed: () {
                          Navigator.pop(context, ('ลากิจเพื่อเลี้ยงดูบุตร', config!.parental));
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
        )
    );
  }
}