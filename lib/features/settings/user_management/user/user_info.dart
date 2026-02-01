import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/profile_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_role_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserInfo extends StatefulWidget {

  final UserManagementModel userInfo;

  const UserInfo({super.key, required this.userInfo});

  @override
  State<StatefulWidget> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {

    String userName = widget.userInfo.nameTH;

    return AppScaffold(
      header: Header.subHeader(context, title: 'แก้ไข: $userName'),
      content: SafeArea(

        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),

                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 13,
                            children: [
                              SeparatorCard(
                                  separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                  children: [
                                    ProfileButton(disable: true, icon: Image.network(widget.userInfo.avatarUrl, fit: BoxFit.cover), title: widget.userInfo.nameTH, subTitle: widget.userInfo.nameEN,)
                                  ]
                              ),
                              SeparatorCard(
                                  separatorPadding: EdgeInsets.only(left: 15, right: 15),
                                  children: [
                                    TextValueButton(label: 'เลขประจำตัวประชาชน', value: widget.userInfo.id, disable: true),
                                    TextValueButton(onPressed: () async {

                                      PushPopup(
                                        buttonLabel: 'บันทึก',
                                        buttonAction: () {},
                                        content: Text('Hello World')
                                      ).showPopup(context);
                                      // final result = await AppPopup.showAlert(
                                      //   context: context,
                                      //   title: "Delete User",
                                      //   message: "Are you sure?",
                                      // );
                                      //
                                      // if (result == true) {
                                      //   print("Confirmed");
                                      // }

                                      // AppPopup.showBottomPopup(
                                      //   context: context,
                                      //   child: Container(
                                      //     padding: const EdgeInsets.all(20),
                                      //     decoration: const BoxDecoration(
                                      //       color: Colors.white,
                                      //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      //     ),
                                      //     child: const Text("Hello Popup"),
                                      //   ),
                                      // );
                                    }, label: 'รหัสบุคลากร', value: widget.userInfo.employeeId),
                                    TextValueButton(label: 'ชื่อ-นามสกุล', value: widget.userInfo.nameTH),
                                    TextValueButton(label: 'Full Name', value: widget.userInfo.nameEN),
                                    TextValueButton(label: 'เพศ', value: widget.userInfo.gender),
                                    TextValueButton(label: 'สัญชาติ', value: widget.userInfo.nationality),
                                    TextValueButton(label: 'เบอร์โทร', value: widget.userInfo.phone),
                                    TextValueButton(label: 'อีเมล', value: widget.userInfo.email, disable: true),
                                  ]
                              ),

                              SeparatorCard(
                                  separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                  children: [
                                    TextRoleButton(disable: false, label: 'ตำแหน่งปัจจุบัน', roles: widget.userInfo.roles, icon: SvgPicture.asset('assets/images/icon_role.svg')),
                                    IconTextButton(icon: 'max_leave_count.svg', label: 'จำนวนวันลาสูงสุด')
                                  ]
                              ),
                              SeparatorCard(
                                  separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                  children: [
                                    IconTextButton(arrow: false, color: Colors.red, icon: 'icon_delete.svg', label: 'ลบผู้ใช้งาน')
                                  ]
                              ),
                            ]
                        )
                    )
                  )
                ],
              )
            )
          )
      )
    );
  }

}