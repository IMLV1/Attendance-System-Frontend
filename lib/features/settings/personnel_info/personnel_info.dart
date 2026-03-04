import 'package:attendance_system/features/settings/personnel_info/choose_personnel.dart';
import 'package:attendance_system/features/settings/personnel_info/overall_info.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_attendance.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_attendance_request.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_data.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_leave.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_statistic.dart';
import 'package:attendance_system/features/settings/user_management/user/user_info.dart';
import 'package:attendance_system/services/personnel_info/personnel_info_model.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/text_button.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter_svg/flutter_svg.dart';

class PersonnelInfo extends StatefulWidget {

  const PersonnelInfo({super.key});

  @override
  State<StatefulWidget> createState() => _PersonnelInfoState();
}

class _PersonnelInfoState extends State<PersonnelInfo> {

  PersonnelInfoModel? userInfo;

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'ข้อมูลบุคลากรในองค์กร'
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
                          child: Column(
                            spacing: 13,
                            children: [
                              SeparatorCard(
                                children: [
                                  (userInfo != null) ?
                                  UserInfoButton(
                                    icon: Image.network(
                                      userInfo!.avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Image.asset('assets/images/profile.png'),
                                    ),
                                    title: userInfo!.nameTH,
                                    subTitle: userInfo!.nameEN,
                                    roles: [
                                      ...userInfo!.roles,
                                      Role(id: '0000000000', name: userInfo!.initRole, color: Color(0xFF535353))
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
                                                    userInfo = personnel;
                                                  });
                                                }
                                            );
                                          }
                                      ).showPopup(context);
                                    },
                                  ) :
                                  TextButton(
                                    label: 'เลือกบุคลากร',
                                    color: Color(0xFF7F7F7F),
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
                                                userInfo = personnel;
                                              });
                                            }
                                          );
                                        }
                                      ).showPopup(context);
                                    },
                                  ),
                                ],
                              ),
                              if (userInfo != null)
                                SeparatorCard(
                                  separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                                  children: [
                                    IconTextButton(
                                      icon: 'icon_profile.svg',
                                      label: 'ข้อมูลส่วนตัว',
                                      onPressed: () async {
                                        final personnel = await Navigator.of(context).push<PersonnelInfoModel>(
                                            MaterialPageRoute(
                                                builder: (_) => PersonnelData(personnel: userInfo!)
                                            )
                                        );
                                        if (!mounted) return;
                                        setState(() {
                                          userInfo = personnel ?? userInfo;
                                        });
                                      },
                                    ),
                                    IconTextButton(
                                      icon: 'icon_attendance_history.svg',
                                      label: 'การเข้างาน',
                                      onPressed: () async {
                                        final personnel = await Navigator.of(context).push<PersonnelInfoModel>(
                                            MaterialPageRoute(
                                                builder: (_) => PersonnelAttendance(personnel: userInfo!)
                                            )
                                        );
                                        if (!mounted) return;
                                        setState(() {
                                          userInfo = personnel ?? userInfo;
                                        });
                                      },
                                    ),
                                    IconTextButton(
                                      icon: 'icon_leave.svg',
                                      label: 'การลางาน',
                                      onPressed: () async {
                                        final personnel = await Navigator.of(context).push<PersonnelInfoModel>(
                                          MaterialPageRoute(
                                            builder: (_) => PersonnelLeave(personnel: userInfo!)
                                          )
                                        );

                                        if (!mounted) return;

                                        setState(() {
                                          userInfo = personnel ?? userInfo;
                                        });
                                      },
                                    ),
                                    IconTextButton(
                                      icon: 'icon_attendance_request_history.svg',
                                      label: 'การขออนุมัติเวลางาน',
                                      onPressed: () async {
                                        final personnel = await Navigator.of(context).push<PersonnelInfoModel>(
                                          MaterialPageRoute(
                                            builder: (_) => PersonnelAttendanceRequest(personnel: userInfo!)
                                          )
                                        );
                                        if (!mounted) return;
                                        setState(() {
                                          userInfo = personnel ?? userInfo;
                                        });
                                      },
                                    ),
                                    IconTextButton(
                                      icon: 'icon_statistic.svg',
                                      label: 'สถิติ',
                                      onPressed: () async {
                                        final personnel = await Navigator.of(context).push<PersonnelInfoModel>(
                                          MaterialPageRoute(
                                            builder: (_) => PersonnelStatistic(personnel: userInfo!)
                                          )
                                        );
                                        if (!mounted) return;
                                        setState(() {
                                          userInfo = personnel ?? userInfo;
                                        });
                                      },
                                    ),
                                  ],
                                )
                            ],
                          )
                        ),
                        // SeparatorCard(
                        //   children: [
                        //     IconTextButton(
                        //       icon: 'icon_personnel_info.svg',
                        //       label: 'ภาพรวมบุคลากร',
                        //       onPressed: () {
                        //         Navigator.of(context).push<PersonnelInfoModel>(
                        //           MaterialPageRoute(
                        //             builder: (_) => OverallInfo()
                        //           )
                        //         );
                        //       },
                        //     )
                        //   ],
                        // )
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