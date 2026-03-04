import 'package:attendance_system/features/settings/personnel_info/choose_personnel.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_attendance.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_attendance_request.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_leave.dart';
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

class OverallInfo extends StatefulWidget {

  const OverallInfo({super.key});

  @override
  State<StatefulWidget> createState() => _OverallInfoState();
}

class _OverallInfoState extends State<OverallInfo> {

  PersonnelInfoModel? userInfo;

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
        header: Header.subHeader(
            context,
            title: 'ภาพรวมบุคลากร'
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