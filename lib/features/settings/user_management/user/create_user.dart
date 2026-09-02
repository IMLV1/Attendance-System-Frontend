import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/features/settings/user_management/user/set_max_leave.dart';
import 'package:attendance_system/main.dart';
import 'package:attendance_system/services/max_leave/max_leave_model.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/services/user_management/user_management_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/option_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/text_input_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:attendance_system/shared/widgets/utils/text_value_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<StatefulWidget> createState() => _CreateUserState();

}

class _CreateUserState extends State<CreateUser> {

  String? error;
  /// 🚩 (2026-09-03) ค่าตั้งต้นตามเอกสารสิทธิ์การลา — เดิมเป็น 0 ทุกช่อง ผู้สร้าง
  /// ผู้ใช้ต้องพิมพ์เองทั้ง 9 ช่องทุกครั้ง (backend ก็ใช้ default_days ของ
  /// leave_types เป็นตัวสำรองอยู่แล้ว ตรงนี้แค่ให้ฟอร์มโชว์เลขเดียวกัน)
  MaxLeaveModel maxLeave = MaxLeaveModel(
    sick: 60,
    personal: 45,
    vacation: 30,
    maternity: 180,
    paternity: 60,
    parental: 150,
    ordination: 120,
    military: 365,
    rehabilitation: 365,
  );
  UserManagementModel userInfo = UserManagementModel(id: '', employeeId: '', nameTH: '', nameEN: '', gender: '', nationality: '', phone: '', email: '', roles: [], avatarUrl: '', initRole: '');

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // 🚩 (2026-08-27) เดิมไม่ได้ระบุ maxWidth เลยตกไปใช้ค่า default
      // (dashboard = 1100) ทั้งที่หน้านี้เป็นฟอร์มคอลัมน์เดียว ผลคือบนจอกว้าง
      // ช่องกรอกช่องเดียวยืดยาวเป็นพันพิกเซล
      maxWidth: Responsive.widthFor(ContentShape.form),
      header: Header.subHeader(
        context,
        title: 'เพิ่มผู้ใช้'
      ),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              spacing: 13,
                              children: [
                                SeparatorCard(
                                    separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                    children: [
                                      IconTextValueButton(onPressed: () {
                                        TextInputPopup(
                                            title: 'อีเมล',
                                            fieldLabel: 'อีเมล',
                                            buttonLabel: 'บันทึก',
                                            maxHeight: 700,
                                            keyboardType: TextInputType.emailAddress,
                                            fit: FlexFit.tight,
                                            currentValue: userInfo.email,
                                            check: (value) {
                                              return (value?.isEmpty ?? true) ? 'อีเมลไม่ถูกต้อง' : null;
                                            },
                                            onSubmit: (value) {
                                              setState(() {
                                                userInfo = userInfo.copyWith(email: value);
                                              });
                                            }
                                        ).showPopup(context);
                                      }, label: 'อีเมล', value: userInfo.email, icon: 'email.svg'),
                                      IconTextValueButton(onPressed: () {
                                        TextInputPopup(
                                            title: 'เลขประจำตัวประชาชน',
                                            fieldLabel: 'เลขประจำตัวประชาชน',
                                            buttonLabel: 'บันทึก',
                                            maxHeight: 700,
                                            fit: FlexFit.tight,
                                            currentValue: userInfo.id,
                                            check: (value) {
                                              return (value?.isEmpty ?? true) ? 'เลขประจำตัวประชาชนไม่ถูกต้อง' : null;
                                            },
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(13),
                                            ],
                                            onSubmit: (value) {
                                              setState(() {
                                                userInfo = userInfo.copyWith(id: value);
                                              });
                                            }
                                        ).showPopup(context);
                                      }, label: 'เลขประจำตัวประชาชน', value: userInfo.id, icon: 'national_id.svg',),
                                    ]
                                ),

                                SeparatorCard(
                                    separatorPadding: EdgeInsets.only(left: 15, right: 15),
                                    children: [
                                      TextValueButton(onPressed: () {
                                        TextInputPopup(
                                            title: 'รหัสบุคลากร',
                                            fieldLabel: 'รหัสบุคลากร',
                                            buttonLabel: 'บันทึก',
                                            maxHeight: 700,
                                            fit: FlexFit.tight,
                                            currentValue: userInfo.employeeId,
                                            check: (value) {
                                              return (value?.isEmpty ?? true) ? 'รหัสบุคลากรไม่ถูกต้อง' : null;
                                            },
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
                                            check: (value) {
                                              return (value?.isEmpty ?? true) ? 'ชื่อไม่ถูกต้อง' : null;
                                            },
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
                                            check: (value) {
                                              return (value?.isEmpty ?? true) ? 'ชื่อไม่ถูกต้อง' : null;
                                            },
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
                                            options: const ['ชาย', 'หญิง', 'อื่นๆ'],
                                            buttonLabel: 'บันทึก',
                                            maxHeight: 700,
                                            fit: FlexFit.tight,
                                            selected: userInfo.gender,
                                            check: (value) {
                                              return (value?.isEmpty ?? true) ? 'กรุณาระบุเพศ' : null;
                                            },
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
                                            check: (value) {
                                              return (value?.isEmpty ?? true) ? 'กรุณาระบุสัญชาติ' : null;
                                            },
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
                                            onSubmit: (value) {
                                              setState(() {
                                                userInfo = userInfo.copyWith(phone: value);
                                              });
                                            }
                                        ).showPopup(context);
                                      }, label: 'เบอร์โทร', value: userInfo.phone),
                                    ]
                                ),
                                SeparatorCard(
                                    separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                    children: [
                                      IconTextValueButton(onPressed: () {
                                        TextInputPopup(
                                            title: 'สังกัด',
                                            fieldLabel: 'สังกัด',
                                            buttonLabel: 'บันทึก',
                                            maxHeight: 700,
                                            fit: FlexFit.tight,
                                            currentValue: userInfo.initRole,
                                            check: (value) {
                                              return (value?.isEmpty ?? true) ? 'กรุณาระบุสังกัด' : null;
                                            },
                                            onSubmit: (value) {
                                              setState(() {
                                                userInfo = userInfo.copyWith(initRole: value);
                                              });
                                            }
                                        ).showPopup(context);
                                      }, label: 'สังกัด', value: userInfo.initRole, icon: 'init_role.svg',),
                                      IconTextButton(onPressed: () async {
                                        MaxLeaveModel? updated = await Navigator.of(context).push(
                                          MaterialPageRoute<MaxLeaveModel>(
                                              builder: (context) => SetMaxLeave(maxLeave: maxLeave)
                                          ),
                                        );

                                        if (updated != null) {
                                          setState(() {
                                            maxLeave = updated;
                                          });
                                        }
                                      }, icon: 'max_leave_count.svg', label: 'จำนวนวันลาสูงสุด')
                                    ]
                                ),
                                SizedBox(height: 60)
                              ],
                            )
                        )
                    )
                  ]
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ServiceUpdater(
                        request: () => UserManagementService().createUser(userInfo, maxLeave),
                        onSuccess: () {
                          Navigator.of(context).pop(userInfo);
                        },
                        builder: (trigger, state, errorMessage) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton.icon(
                                  onPressed: (state != ServiceUpdatorState.loading) ? () {

                                    if (
                                      userInfo.email.isNotEmpty &&
                                      userInfo.id.isNotEmpty &&
                                      userInfo.employeeId.isNotEmpty &&
                                      userInfo.nameTH.isNotEmpty &&
                                      userInfo.nameEN.isNotEmpty &&
                                      userInfo.gender.isNotEmpty &&
                                      userInfo.nationality.isNotEmpty &&
                                      userInfo.phone.isNotEmpty &&
                                      userInfo.initRole.isNotEmpty
                                    ) {
                                      trigger();
                                    } else {
                                      setState(() {
                                        error = 'เกิดข้อผิดพลาด: ข้อมูลไม่ครบถ้วน';
                                      });
                                    }

                                  } : null,
                                  icon: SvgPicture.asset(
                                    'assets/images/create.svg',
                                    height: 18,
                                    width: 18,
                                    colorFilter: ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  label: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 10,
                                    children: [
                                      Text(
                                        'สร้าง',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (state == ServiceUpdatorState.loading) CupertinoActivityIndicator(color: Colors.white)
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey,
                                    backgroundColor: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 25,
                                child: (error != null) ?
                                Text(
                                    error!,
                                    style: TextStyle(
                                        color: Colors.red
                                    )
                                )
                                : (state == ServiceUpdatorState.error) ?
                                Text(
                                    errorMessage,
                                    style: TextStyle(
                                        color: Colors.red
                                    )
                                ) : SizedBox()
                              )
                            ],
                          );
                        }
                      )
                    ],
                  ),
              ],
            )
          )
        )
      )
    );
  }
}