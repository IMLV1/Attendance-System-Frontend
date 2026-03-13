import 'package:attendance_system/features/settings/personnel_info/choose_personnel.dart';
import 'package:attendance_system/services/personnel_info/personnel_data_service.dart';
import 'package:attendance_system/services/personnel_info/personnel_info_model.dart';
import 'package:attendance_system/services/profile_page/profile_model.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater_promax.dart';
import 'package:attendance_system/shared/widgets/utils/text_role_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonnelData extends StatefulWidget {

  final PersonnelInfoModel personnel;

  const PersonnelData({super.key, required this.personnel});

  @override
  State<StatefulWidget> createState() => _PersonnelDataState();

}

class _PersonnelDataState extends State<PersonnelData> {

  PersonnelInfoModel? personnel;
  ProfileModel? profile;

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
        title: 'ข้อมูลส่วนตัว',
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
                    child: ServiceUpdaterProMax(
                      requests: [
                        () => PersonnelDataService().getData(personnel!.id), /*Utils.mockResponse(
                          data: {
                            "user_id": "1800400370922",
                            "employee_id": "6630300394",
                            "email": "teetat.p@ku.th",
                            "fullname_eng": "Teetat Pitanupong",
                            "fullname_thai": "ธีธัช ปิตานุพงศ์",
                            "gender": "ชาย",
                            "nationality": "ไทย",
                            "phone": "098-445-1535",
                            'roles': [
                              {'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
                              {'role-name': 'รองคณบดี', 'role-color': 'FFA51D'},
                              {'role-name': 'วิศวกรรมคอมพิวเตอร์', 'role-color': '535353'}
                            ],
                            "picture":"https://tse3.mm.bing.net/th/id/OIP.QW_5l0R799_ZMX53fzcUYwHaHd?rs=1&pid=ImgDetMain&o=7&rm=3",
                          }
                        )*/
                      ],
                      onSuccess: (index, data) {
                        switch (index) {
                          case 0: profile = ProfileModel.fromJson(data);
                        }
                      },
                      fetchOnInit: true,
                      builder: (trigger, getState) {
                        return Column(
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
                                                    trigger(0);
                                                  }
                                              );
                                            }
                                        ).showPopup(context);
                                      },
                                    )
                                  ],
                                )
                            ),
                            (getState(0) == ServiceUpdaterProMaxState.loading) ? CupertinoActivityIndicator() :
                            Column(
                              spacing: 13,
                              children: [
                                SeparatorCard(
                                  separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 15),
                                  children: [
                                    TextValueButton(
                                      // color: Color(0xFF949494),
                                        disable: true,
                                        label: 'รหัสบุคลากร',
                                        value: profile?.staffId ?? '---'
                                    ),
                                    TextValueButton(
                                      // color: Color(0xFF949494),
                                        disable: true,
                                        label: 'เลขบัตรประจำตัวประชาชน',
                                        value: profile?.citizenId ?? '---'
                                    ),
                                    TextValueButton(
                                      // color: Color(0xFF949494),
                                        disable: true,
                                        label: 'ชื่อ-นามสกุล',
                                        value: profile?.thName ?? '---'
                                    ),
                                    TextValueButton(
                                      // color: Color(0xFF949494),
                                        disable: true,
                                        label: 'Full-name',
                                        value: profile?.enName ?? '---'
                                    ),
                                    TextValueButton(
                                      // color: Color(0xFF949494),
                                        disable: true,
                                        label: 'เพศ',
                                        value: profile?.gender ?? '---'
                                    ),
                                    TextValueButton(
                                      // color: Color(0xFF949494),
                                        disable: true,
                                        label: 'สัญชาติ',
                                        value: profile?.nationality ?? '---'
                                    ),
                                    TextValueButton(
                                      // color: Color(0xFF949494),
                                        disable: true,
                                        label: 'เบอร์โทร',
                                        value: profile?.phone ?? '---'
                                    ),
                                    TextValueButton(
                                      // color: Color(0xFF949494),
                                        disable: true,
                                        label: 'อีเมล',
                                        value: profile?.email ?? '---'
                                    ),
                                  ],
                                ),
                                SeparatorCard(
                                  children: [
                                    TextRoleButton(
                                      disable: true,
                                      label: 'ตำแหน่งปัจจุบัน',
                                      roles: profile?.roles ?? [],
                                      icon: SvgPicture.asset('assets/images/icon_role.svg'),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        );
                      }
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