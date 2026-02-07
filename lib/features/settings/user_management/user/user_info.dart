import 'package:attendance_system/main.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/option_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/text_input_popup.dart';
import 'package:attendance_system/shared/widgets/utils/profile_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_role_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sealed_countries/sealed_countries.dart';

class UserInfo extends StatefulWidget {

  final UserManagementModel userInfo;

  const UserInfo({super.key, required this.userInfo});

  @override
  State<StatefulWidget> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {

  late UserManagementModel userInfo;

  @override
  void initState() {
    super.initState();
    userInfo = widget.userInfo;
  }

  @override
  Widget build(BuildContext context) {

    String userName = userInfo.nameTH;

    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'แก้ไข: $userName',
        onBack: () {
            Navigator.pop(context, userInfo);
        }
      ),
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
                                    ProfileButton(disable: true, icon: Image.network(userInfo.avatarUrl, fit: BoxFit.cover), title: userInfo.nameTH, subTitle: userInfo.nameEN,)
                                  ]
                              ),
                              SeparatorCard(
                                  separatorPadding: EdgeInsets.only(left: 15, right: 15),
                                  children: [
                                    TextValueButton(label: 'เลขประจำตัวประชาชน', value: userInfo.id, disable: true),
                                    TextValueButton(onPressed: () {
                                      TextInputPopup(
                                        title: 'รหัสบุคลากร',
                                        fieldLabel: 'รหัสบุคลากร',
                                        buttonLabel: 'บันทึก',
                                        maxHeight: 700,
                                        fit: FlexFit.tight,
                                        currentValue: userInfo.employeeId,
                                        onSubmit: (value) {
                                          setState(() {
                                            userInfo = userInfo.copyWith(employeeId: value);
                                          });
                                        }
                                      ).showPopup(context);
                                    }, label: 'รหัสบุคลากร', value: userInfo.employeeId),
                                    TextValueButton(onPressed: () {
                                      TextInputPopup(
                                        title: 'ชื่อ-นามสกุล',
                                        fieldLabel: 'ชื่อ-นามสกุล',
                                        buttonLabel: 'บันทึก',
                                        maxHeight: 700,
                                        fit: FlexFit.tight,
                                        currentValue: userInfo.nameTH,
                                        onSubmit: (value) {
                                          setState(() {
                                            userInfo = userInfo.copyWith(nameTH: value);
                                          });
                                        }
                                      ).showPopup(context);
                                    }, label: 'ชื่อ-นามสกุล', value: userInfo.nameTH),
                                    TextValueButton(onPressed: () {
                                      TextInputPopup(
                                        title: 'Full Name',
                                        fieldLabel: 'Full Name',
                                        buttonLabel: 'บันทึก',
                                        maxHeight: 700,
                                        fit: FlexFit.tight,
                                        currentValue: userInfo.nameEN,
                                        onSubmit: (value) {
                                          setState(() {
                                            userInfo = userInfo.copyWith(nameEN: value);
                                          });
                                        }
                                      ).showPopup(context);
                                    }, label: 'Full Name', value: userInfo.nameEN),
                                    TextValueButton(onPressed: () {
                                      OptionPopup(
                                          title: 'เพศ',
                                          options: ['ชาย', 'หญิง', 'เกย์', 'กระเทย', 'มึงสิอิกะเทย', 'อื่นๆ'],
                                          buttonLabel: 'บันทึก',
                                          maxHeight: 700,
                                          fit: FlexFit.tight,
                                          selected: userInfo.gender,
                                          onSubmit: (value) {
                                            setState(() {
                                              userInfo = userInfo.copyWith(gender: value);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, label: 'เพศ', value: userInfo.gender),
                                    TextValueButton(onPressed: () {
                                      OptionPopup(
                                          title: 'สัญชาติ',
                                          options: cachedThaiNationalities,
                                          buttonLabel: 'บันทึก',
                                          maxHeight: 700,
                                          fit: FlexFit.tight,
                                          selected: userInfo.nationality,
                                          onSubmit: (value) {
                                            setState(() {
                                              userInfo = userInfo.copyWith(nationality: value);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, label: 'สัญชาติ', value: userInfo.nationality),
                                    TextValueButton(onPressed: () {
                                      TextInputPopup(
                                        title: 'เบอร์โทร',
                                        fieldLabel: 'เบอร์โทร',
                                        buttonLabel: 'บันทึก',
                                        maxHeight: 700,
                                        fit: FlexFit.tight,
                                        currentValue: userInfo.phone,
                                        onSubmit: (value) {
                                          setState(() {
                                            userInfo = userInfo.copyWith(phone: value);
                                          });
                                        }
                                      ).showPopup(context);
                                    }, label: 'เบอร์โทร', value: userInfo.phone),
                                    TextValueButton(label: 'อีเมล', value: userInfo.email, disable: true),
                                  ]
                              ),

                              SeparatorCard(
                                  separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                  children: [
                                    TextRoleButton(disable: false, label: 'ตำแหน่งปัจจุบัน', roles: userInfo.roles, icon: SvgPicture.asset('assets/images/icon_role.svg')),
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