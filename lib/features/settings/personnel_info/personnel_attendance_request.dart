import 'package:attendance_system/features/settings/personnel_info/choose_personnel.dart';
import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:attendance_system/services/personnel_info/personnel_info_model.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PersonnelAttendanceRequest extends StatefulWidget {

  final PersonnelInfoModel personnel;

  const PersonnelAttendanceRequest({super.key, required this.personnel});

  @override
  State<StatefulWidget> createState() => _PersonnelAttendanceRequestState();

}

class _PersonnelAttendanceRequestState extends State<PersonnelAttendanceRequest> {

  PersonnelInfoModel? personnel;

  List<PendingLeaveRequestModel> pendingLeaves = [];
  List<LeaveRequestModel> recentLeaves = [];

  int permissionLevel = 0;

  DateTime? filterStartAllow;
  DateTime? filterEndAllow;

  DateTime? filterStart;
  DateTime? filterEnd;

  @override
  void initState() {
    super.initState();
    personnel = widget.personnel;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'บันทึกการขออนุมัติเวลางาน',
        onBack: () {
          Navigator.of(context).pop(personnel);
        }
      ),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: 10, right: 10, top: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      spacing: 13,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFE3E3E3),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 14),
                          child: SeparatorCard(
                            children: [
                              UserInfoButton(
                                icon: Image.network(
                                  personnel!.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Image.asset('assets/images/profile.svg'),
                                ),
                                title: personnel!.nameTH,
                                subTitle: personnel!.nameEN,
                                roles: [
                                  ...personnel!.roles,
                                  Role(id: '0000000000', name: personnel!.initRole, color: Color(0xFF535353))
                                ],
                                onPressed: () {
                                  PushPopup(
                                      title: 'เลือกบุคลากร',
                                      fit: FlexFit.tight,
                                      maxHeight: 700,
                                      scroll: false,
                                      builder: (BuildContext context) {
                                        return ChoosePersonnel(
                                            onChoose: (personnel) {
                                              setState(() {
                                                this.personnel = personnel;
                                              });
                                            }
                                        );
                                      }
                                  ).showPopup(context);
                                },
                              )
                            ],
                          )
                        )
                      ]
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