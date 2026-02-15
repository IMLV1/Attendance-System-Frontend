import 'package:attendance_system/features/settings/user_management/user/assign_role.dart';
import 'package:attendance_system/features/settings/user_management/user/max_leave.dart';
import 'package:attendance_system/main.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/services/user_management/user_management_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/floating_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/option_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/option_service_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/text_service_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/text_input_popup.dart';
import 'package:attendance_system/shared/widgets/utils/profile_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:attendance_system/shared/widgets/utils/text_role_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_value_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
            Navigator.pop(context, (status: 0, updatedUser: userInfo));
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
                                    ProfileButton(
                                      disable: true,
                                      icon: Image.network(
                                        userInfo.avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/profile.png',
                                            fit: BoxFit.cover,
                                          );
                                        },
                                    ), title: userInfo.nameTH, subTitle: userInfo.nameEN,)
                                  ]
                              ),
                              SeparatorCard(
                                  separatorPadding: EdgeInsets.only(left: 15, right: 15),
                                  children: [
                                    TextValueButton(label: 'เลขประจำตัวประชาชน', value: userInfo.id, disable: true),
                                    TextValueButton(onPressed: () {
                                      TextServicePopup(
                                        title: 'รหัสบุคลากร',
                                        fieldLabel: 'รหัสบุคลากร',
                                        buttonLabel: 'บันทึก',
                                        maxHeight: 700,
                                        fit: FlexFit.tight,
                                        currentValue: userInfo.employeeId,
                                        check: (value) {
                                          return (value?.isEmpty ?? true) ? 'รหัสบุคลากรไม่ถูกต้อง' : null;
                                        },
                                        request: (value) => UserManagementService().updateUserInfo(userInfo.copyWith(employeeId: value)),
                                        onSuccess: (value) {
                                          setState(() {
                                            userInfo = userInfo.copyWith(employeeId: value);
                                          });
                                        }
                                      ).showPopup(context);
                                    }, label: 'รหัสบุคลากร', value: userInfo.employeeId),
                                    TextValueButton(onPressed: () {
                                      TextServicePopup(
                                        title: 'ชื่อ-นามสกุล',
                                        fieldLabel: 'ชื่อ-นามสกุล',
                                        buttonLabel: 'บันทึก',
                                        maxHeight: 700,
                                        fit: FlexFit.tight,
                                        currentValue: userInfo.nameTH,
                                        check: (value) {
                                          return (value?.isEmpty ?? true) ? 'ชื่อไม่ถูกต้อง' : null;
                                        },
                                        request: (value) => UserManagementService().updateUserInfo(userInfo.copyWith(nameTH: value)),
                                        onSuccess: (value) {
                                          setState(() {
                                            userInfo = userInfo.copyWith(nameTH: value);
                                          });
                                        }
                                      ).showPopup(context);
                                    }, label: 'ชื่อ-นามสกุล', value: userInfo.nameTH),
                                    TextValueButton(onPressed: () {
                                      TextServicePopup(
                                        title: 'Full Name',
                                        fieldLabel: 'Full Name',
                                        buttonLabel: 'บันทึก',
                                        maxHeight: 700,
                                        fit: FlexFit.tight,
                                        currentValue: userInfo.nameEN,
                                        check: (value) {
                                          return (value?.isEmpty ?? true) ? 'ชื่อไม่ถูกต้อง' : null;
                                        },
                                        request: (value) => UserManagementService().updateUserInfo(userInfo.copyWith(nameEN: value)),
                                        onSuccess: (value) {
                                          setState(() {
                                            userInfo = userInfo.copyWith(nameEN: value);
                                          });
                                        }
                                      ).showPopup(context);
                                    }, label: 'Full Name', value: userInfo.nameEN),
                                    TextValueButton(onPressed: () {
                                      OptionServicePopup(
                                          title: 'เพศ',
                                          options: ['ชาย', 'หญิง', 'เกย์', 'กระเทย', 'มึงสิอิกะเทย', 'อื่นๆ'],
                                          buttonLabel: 'บันทึก',
                                          maxHeight: 700,
                                          fit: FlexFit.tight,
                                          selected: userInfo.gender,
                                          check: (value) {
                                            return (value?.isEmpty ?? true) ? 'กรุณาระบุเพศ' : null;
                                          },
                                          request: (value) => UserManagementService().updateUserInfo(userInfo.copyWith(gender: value)),
                                          onSuccess: (value) {
                                            setState(() {
                                              userInfo = userInfo.copyWith(gender: value);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, label: 'เพศ', value: userInfo.gender),
                                    TextValueButton(onPressed: () {
                                      OptionServicePopup(
                                          title: 'สัญชาติ',
                                          options: cachedThaiNationalities,
                                          buttonLabel: 'บันทึก',
                                          maxHeight: 700,
                                          fit: FlexFit.tight,
                                          selected: userInfo.nationality,
                                          check: (value) {
                                            return (value?.isEmpty ?? true) ? 'กรุณาระบุสัญชาติ' : null;
                                          },
                                          request: (value) => UserManagementService().updateUserInfo(userInfo.copyWith(nationality: value)),
                                          onSuccess: (value) {
                                            setState(() {
                                              userInfo = userInfo.copyWith(nationality: value);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, label: 'สัญชาติ', value: userInfo.nationality),
                                    TextValueButton(onPressed: () {
                                      TextServicePopup(
                                        title: 'เบอร์โทร',
                                        fieldLabel: 'เบอร์โทร',
                                        buttonLabel: 'บันทึก',
                                        maxHeight: 700,
                                        inputFormatters: [
                                          MaskTextInputFormatter(
                                            mask: '###-###-####',
                                            filter: { "#": RegExp(r'[0-9]') },
                                          )
                                        ],
                                        keyboardType: TextInputType.phone,
                                        fit: FlexFit.tight,
                                        currentValue: userInfo.phone,
                                        check: (value) {

                                          if (value == null) return null;

                                          final regex = RegExp(r'^\d{3}-\d{3}-\d{4}$');

                                          return (value.isEmpty || !regex.hasMatch(value)) ? 'เบอร์โทรไม่ถูกต้อง' : null;
                                        },
                                        request: (value) => UserManagementService().updateUserInfo(userInfo.copyWith(phone: value)),
                                        onSuccess: (value) {
                                          setState(() {
                                            userInfo = userInfo.copyWith(phone: value);
                                          });
                                        }
                                      ).showPopup(context);
                                    }, label: 'เบอร์โทร', value: userInfo.phone),
                                    TextValueButton(onPressed: () {
                                      TextServicePopup(
                                          title: 'สังกัด',
                                          fieldLabel: 'สังกัด',
                                          buttonLabel: 'บันทึก',
                                          maxHeight: 700,
                                          fit: FlexFit.tight,
                                          currentValue: userInfo.initRole,
                                          check: (value) {
                                            return (value?.isEmpty ?? true) ? 'กรุณาระบุสังกัด' : null;
                                          },
                                          request: (value) => UserManagementService().updateUserInfo(userInfo.copyWith(initRole: value)),
                                          onSuccess: (value) {
                                            setState(() {
                                              userInfo = userInfo.copyWith(initRole: value);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, label: 'สังกัด', value: userInfo.initRole),
                                    TextValueButton(label: 'อีเมล', value: userInfo.email, disable: true),
                                  ]
                              ),

                              SeparatorCard(
                                  separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                  children: [
                                    TextRoleButton(onPressed: () async {
                                      List<Role>? updatedRole = await Navigator.of(context).push(
                                        MaterialPageRoute<List<Role>>(
                                          builder: (context) => AssignRole(id: userInfo.id, title: 'ตำแหน่ง: ${userInfo.nameTH}', roles: userInfo.roles)
                                        ),
                                      );

                                      if (updatedRole != null) {
                                        setState(() {
                                          userInfo = userInfo.copyWith(roles: updatedRole);
                                        });
                                      }

                                    }, label: 'ตำแหน่งปัจจุบัน', roles: [...userInfo.roles], icon: SvgPicture.asset('assets/images/icon_role.svg')),
                                    IconTextButton(onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => MaxLeave(id: userInfo.id, title: 'จำนวนวันลา: ${userInfo.nameTH}')
                                        ),
                                      );
                                    }, icon: 'max_leave_count.svg', label: 'จำนวนวันลาสูงสุด')
                                  ]
                              ),

                              SeparatorCard(
                                  separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                  children: [
                                    IconTextButton(onPressed: () {
                                      FloatingPopup(
                                        title: 'ลบผู้ใช้งาน',
                                        description: 'คุณยืนยันที่จะลบผู้ใช้ ${userInfo.nameTH} หรือไม่ การดำเนินการนี้จะไม่สามารถย้อนกลับมาได้อีก',
                                        buttons: (parent, context1) => [
                                          FloatingPopupButton(onPressed: () {
                                            Navigator.of(context1).pop();
                                          }, text: 'ยกเลิก', foregroundColor: Colors.white, backgroundColor: AppColors.primaryColor, ),
                                          FloatingServicePopupButton(onSuccess: () {
                                            Navigator.of(context1).pop();
                                            Navigator.pop(context, (status: 1, updatedUser: null));
                                          }, text: 'ลบ', foregroundColor: Colors.red, request: () => UserManagementService().deleteUser(userInfo.id), setError: parent)
                                        ]
                                      ).showPopup(context);
                                    }, arrow: false, color: Colors.red, icon: 'icon_delete.svg', label: 'ลบผู้ใช้งาน')
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