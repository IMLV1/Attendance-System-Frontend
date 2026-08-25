import 'package:attendance_system/features/settings/personnel_info/choose_personnel.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_attendance.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_attendance_request.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_data.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_leave.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_statistic.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/services/personnel_info/personnel_info_model.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/text_button.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter_svg/flutter_svg.dart';

/// หัวข้อย่อยของบุคลากรหนึ่งคน — บนจอแคบเป็นเมนูที่กดแล้ว push หน้าใหม่
/// บนจอกว้างเป็นแท็บของคอลัมน์ขวา
enum _Section {
  data('ข้อมูลส่วนตัว', 'icon_profile.svg'),
  attendance('การเข้างาน', 'icon_attendance_history.svg'),
  leave('การลางาน', 'icon_leave.svg'),
  request('การขออนุมัติเวลางาน', 'icon_attendance_request_history.svg'),
  statistic('สถิติ', 'icon_statistic.svg');

  final String label;
  final String icon;
  const _Section(this.label, this.icon);
}

class PersonnelInfo extends StatefulWidget {

  const PersonnelInfo({super.key});

  @override
  State<StatefulWidget> createState() => _PersonnelInfoState();
}

class _PersonnelInfoState extends State<PersonnelInfo> {

  PersonnelInfoModel? userInfo;

  /// หัวข้อที่เปิดอยู่ในคอลัมน์ขวา — ใช้เฉพาะจอกว้าง
  _Section _section = _Section.data;

  void _choose(PersonnelInfoModel personnel) {
    setState(() => userInfo = personnel);
  }

  /// เนื้อหาของหัวข้อที่เลือก แบบฝังในคอลัมน์ขวา (ไม่มีแถบหัวของตัวเอง)
  ///
  /// ผูก key กับ id ของคนที่เลือก เพื่อให้สลับคนแล้วสร้าง state ใหม่ทั้งก้อน
  /// ไม่ใช่เอา state ของคนเดิมมาใช้ต่อ
  Widget _sectionBody(PersonnelInfoModel personnel) {
    final key = ValueKey('${_section.name}-${personnel.id}');
    return switch (_section) {
      _Section.data =>
          PersonnelData(key: key, personnel: personnel, embedded: true),
      _Section.attendance =>
          PersonnelAttendance(key: key, personnel: personnel, embedded: true),
      _Section.leave =>
          PersonnelLeave(key: key, personnel: personnel, embedded: true),
      _Section.request => PersonnelAttendanceRequest(
          key: key, personnel: personnel, embedded: true),
      _Section.statistic =>
          PersonnelStatistic(key: key, personnel: personnel, embedded: true),
    };
  }

  Widget _sectionTabs() {
    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
      // 🚩 ใช้ Wrap ไม่ใช่ Row+Expanded — แท็บกว้างตามข้อความจริง ถ้าที่ไม่พอ
      // ก็ขึ้นบรรทัดใหม่เอง แทนที่จะบีบทุกแท็บให้เท่ากันจนชื่อยาวโดนตัด
      // (บน iPad แนวตั้งคอลัมน์ขวาเหลือ ~670 หาร 5 ได้แท็บละ ~124 ซึ่งสั้นกว่า
      // คำว่า 'การขออนุมัติเวลางาน' อยู่มาก)
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in _Section.values)
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _section = s),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      _section == s ? AppColors.cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _section == s
                        ? const Color(0xFFD8D8D8)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    SvgPicture.asset(
                      'assets/images/${s.icon}',
                      width: 16,
                      height: 16,
                      // 🚩 ต้องย้อมสีเสมอ — ไอคอนชุดนี้สีไม่เหมือนกัน
                      // icon_profile.svg เป็น fill="white" ล้วน (ทำมาสำหรับแถบหัว
                      // สีแดงเข้ม) ถ้าไม่ย้อมจะหายไปกับพื้นขาว ส่วน
                      // icon_attendance_request_history.svg มีทั้งขาวและดำผสมกัน
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF2C2C2C),
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _section == s
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🚩 (Phase 2, 2026-08-25) บนจอกว้างหน้านี้เคยว่างเกือบทั้งหน้า มีแค่ปุ่ม
  /// "เลือกบุคลากร" บรรทัดเดียว ที่เหลือโล่ง ~90% (ดู RESPONSIVE_PLAN.md
  /// หัวข้อ 0.4 รอบสาม ข้อ A) ทั้งที่ข้อมูลที่ต้องดูมี 5 หัวข้อเต็มๆ
  ///
  /// จัดใหม่เป็น master-detail: รายชื่ออยู่ซ้ายตลอดเวลา (ไม่ต้องเปิด popup
  /// เพื่อสลับคน) เนื้อหาของคนที่เลือกอยู่ขวา แยกเป็นแท็บ 5 หัวข้อ
  ///
  /// ผลพลอยได้: 5 หน้านั้นเดิมถูก push ด้วย `Navigator.push(MaterialPageRoute)`
  /// ซึ่งเป็น route ที่ไม่มีใน go_router — เป็นต้นเหตุของบั๊กจอค้าง (ดูบั๊ก #3
  /// ใน RESPONSIVE_PLAN.md) บนจอกว้างจึงไม่ต้อง push อีกต่อไป
  Widget _masterDetail(BuildContext context) {
    final personnel = userInfo;

    return AppScaffold(
      fullWidth: true,
      header: Header.subHeader(context, title: 'ข้อมูลบุคลากรในองค์กร'),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                // 360 เท่ากันทุกโหมด — แคบกว่านี้ป้ายตำแหน่งใน UserInfoButton
                // จะตัดขึ้นบรรทัดใหม่จนแถวสูงไม่เท่ากัน
                width: 360,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: ChoosePersonnel(
                    inline: true,
                    selectedUserId: personnel?.id,
                    onChoose: _choose,
                  ),
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: personnel == null
                    ? const Center(
                        child: Text(
                          'เลือกบุคลากรจากรายการทางซ้าย',
                          style: TextStyle(color: Color(0xFF7F7F7F)),
                        ),
                      )
                    : Column(
                        children: [
                          _sectionTabs(),
                          Expanded(child: _sectionBody(personnel)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // 🚩 (2026-08-25) เปิดใช้ตั้งแต่ medium ขึ้นไป ไม่ใช่เฉพาะ expanded —
    // iPad แนวตั้งกว้าง 1032 พอสำหรับสองคอลัมน์สบายๆ ถ้าปล่อยเป็นเมนูเดิม
    // เนื้อหาจะจบที่ ~15% ของความสูงจอ ที่เหลือโล่งทั้งหมด
    // มือถือ (compact) ยังเป็นเมนูที่กดแล้ว push หน้าใหม่เหมือนเดิม
    if (!Responsive.isCompact(context)) {
      return _masterDetail(context);
    }

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