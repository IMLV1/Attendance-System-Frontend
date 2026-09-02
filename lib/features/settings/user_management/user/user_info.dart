import 'package:attendance_system/core/utils/responsive.dart';
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
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/option_service_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/text_service_popup.dart';
import 'package:attendance_system/shared/widgets/utils/profile_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/text_role_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_value_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class UserInfo extends StatefulWidget {

  final UserManagementModel userInfo;

  /// ฝังเนื้อหาลงในคอลัมน์ขวาของ master-detail แทนการเป็นหน้าเต็ม
  /// — ไม่มีแถบหัวและปุ่ม back เพราะรายการทางซ้ายทำหน้าที่นำทางแทนแล้ว
  final bool embedded;

  /// 🚩 โหมดหน้าเต็มคืนผลลัพธ์ตอน pop ได้ แต่โหมดฝังไม่มี pop ให้คืน
  /// ต้องรายงานกลับทันทีที่แก้ ไม่งั้นรายการทางซ้ายจะค้างชื่อเดิมทั้งที่
  /// ทางขวาเปลี่ยนไปแล้ว
  final ValueChanged<UserManagementModel>? onChanged;

  /// เรียกหลังลบผู้ใช้สำเร็จ (โหมดฝังเท่านั้น)
  final VoidCallback? onDeleted;

  const UserInfo({
    super.key,
    required this.userInfo,
    this.embedded = false,
    this.onChanged,
    this.onDeleted,
  });

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
  void didUpdateWidget(UserInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ในโหมด master-detail widget ตัวเดิมถูกใช้ซ้ำเมื่อสลับคน ถ้าไม่รับค่าใหม่
    // จะค้างข้อมูลของคนก่อนหน้า
    if (widget.userInfo.id != oldWidget.userInfo.id) {
      userInfo = widget.userInfo;
    }
  }

  /// อัปเดตข้อมูลในหน้า แล้วรายงานให้ผู้เรียกรู้ถ้าอยู่ในโหมดฝัง
  void _update(UserManagementModel next) {
    setState(() => userInfo = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {

    String userName = userInfo.nameTH;

    // โหมดฝัง: ไม่มี AppScaffold (จะกลายเป็น Scaffold ซ้อน Scaffold) แต่ยัง
    // ต้องคุมความกว้างเองเพราะคอลัมน์ขวากว้างกว่าฟอร์มมาก
    if (widget.embedded) {
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.widthFor(ContentShape.form),
          ),
          child: _body(context),
        ),
      );
    }

    return AppScaffold(
      // 🚩 (2026-08-27) เดิมไม่ได้ระบุ maxWidth เลยตกไปใช้ค่า default
      // (dashboard = 1100) ทั้งที่หน้านี้เป็นฟอร์มคอลัมน์เดียว ผลคือบนจอกว้าง
      // ช่องกรอกช่องเดียวยืดยาวเป็นพันพิกเซล
      maxWidth: Responsive.widthFor(ContentShape.form),
      header: Header.subHeader(
        context,
        title: 'แก้ไข: $userName',
        onBack: () {
            Navigator.pop(context, (status: 0, updatedUser: userInfo));
        }
      ),
      content: _body(context),
    );
  }

  /// เนื้อหาล้วนๆ ไม่รวมแถบหัว — ใช้ทั้งตอนเป็นหน้าเต็มและตอนถูกฝัง
  Widget _body(BuildContext context) {
    return SafeArea(

        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                          _update(userInfo.copyWith(employeeId: value));
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
                                          _update(userInfo.copyWith(nameTH: value));
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
                                          _update(userInfo.copyWith(nameEN: value));
                                        }
                                      ).showPopup(context);
                                    }, label: 'Full Name', value: userInfo.nameEN),
                                    TextValueButton(onPressed: () {
                                      OptionServicePopup(
                                          title: 'เพศ',
                                          options: const ['ชาย', 'หญิง', 'อื่นๆ'],
                                          buttonLabel: 'บันทึก',
                                          maxHeight: 700,
                                          fit: FlexFit.tight,
                                          selected: userInfo.gender,
                                          check: (value) {
                                            return (value?.isEmpty ?? true) ? 'กรุณาระบุเพศ' : null;
                                          },
                                          request: (value) => UserManagementService().updateUserInfo(userInfo.copyWith(gender: value)),
                                          onSuccess: (value) {
                                            _update(userInfo.copyWith(gender: value));
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
                                            _update(userInfo.copyWith(nationality: value));
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
                                          _update(userInfo.copyWith(phone: value));
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
                                            _update(userInfo.copyWith(initRole: value));
                                          }
                                      ).showPopup(context);
                                    }, label: 'สังกัด', value: userInfo.initRole),
                                    TextValueButton(label: 'อีเมล', value: userInfo.email, disable: true),
                                  ]
                              ),

                              // 🚩 (2026-08-27) เดิมสองแถวนี้ push หน้าใหม่ทับทั้งจอ
                              // ทั้งที่อีก 7 ช่องในหน้าเดียวกันเปิดเป็น popup กันหมด
                              // และบนจอกว้างการ push ยังกลืน master-detail ทั้งอัน
                              SeparatorCard(
                                  separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                  children: [
                                    TextRoleButton(onPressed: () {
                                      PushPopup(
                                        title: 'ตำแหน่ง: ${userInfo.nameTH}',
                                        fit: FlexFit.tight,
                                        maxHeight: 700,
                                        scroll: false,
                                        builder: (_) => AssignRole(
                                          id: userInfo.id,
                                          roles: userInfo.roles,
                                          onSaved: (updated) {
                                            _update(userInfo.copyWith(roles: updated));
                                          },
                                        ),
                                      ).showPopup(context);
                                    }, label: 'ตำแหน่งปัจจุบัน', roles: [...userInfo.roles], icon: SvgPicture.asset('assets/images/icon_role.svg')),
                                  ]
                              ),

                              // จำนวนวันลาเคยเป็นหน้าแยกเหมือนกัน แต่มันเป็นหน้าเดียวกับ
                              // ข้อมูลส่วนตัวข้างบนทุกอย่าง (6 แถวคงที่ เซฟทันทีทีละแถว)
                              // จึงยุบเข้ามาเลย ไม่ต้องมีปุ่มให้กดเข้าไปอีกชั้น
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 5,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Row(
                                      spacing: 6,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/max_leave_count.svg',
                                          width: 15,
                                          height: 15,
                                        ),
                                        const Text('จำนวนวันลาสูงสุด'),
                                      ],
                                    ),
                                  ),
                                  MaxLeaveSection(
                                    // เปลี่ยนคน = โหลดใหม่ทั้งก้อน ไม่ค้างตัวเลขของคนก่อนหน้า
                                    key: ValueKey(userInfo.id),
                                    id: userInfo.id,
                                  ),
                                ],
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
                                            if (widget.embedded) {
                                              widget.onDeleted?.call();
                                            } else {
                                              Navigator.pop(context, (status: 1, updatedUser: null));
                                            }
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
    );
  }
}
