import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/profile_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_role_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_value_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../services/profile_page/profile_model.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/utils/separator_card.dart';

class MockProfile {
  Future<ProfileModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final data = {
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
    };

    return ProfileModel.fromJson(data);
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {

  ProfileModel? profile;

  @override
  Widget build(BuildContext context) {

    profile = context.watch<AuthState>().profile;

    final fieldsCard = SeparatorCard(
      separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 15),
      children: [
        TextValueButton(
            disable: true,
            label: 'รหัสบุคลากร',
            value: profile!.staffId
        ),
        TextValueButton(
            disable: true,
            label: 'เลขบัตรประจำตัวประชาชน',
            value: profile!.citizenId
        ),
        TextValueButton(
            disable: true,
            label: 'ชื่อ-นามสกุล',
            value: profile!.thName
        ),
        TextValueButton(
            disable: true,
            label: 'Full-name',
            value: profile!.enName
        ),
        TextValueButton(
            disable: true,
            label: 'เพศ',
            value: profile!.gender
        ),
        TextValueButton(
            disable: true,
            label: 'สัญชาติ',
            value: profile!.nationality
        ),
        TextValueButton(
            disable: true,
            label: 'เบอร์โทร',
            value: profile!.phone
        ),
        TextValueButton(
            disable: true,
            label: 'อีเมล',
            value: profile!.email
        ),
      ],
    );

    final roleCard = SeparatorCard(
      children: [
        TextRoleButton(
          disable: true,
          label: 'ตำแหน่งปัจจุบัน',
          roles: profile!.roles,
          icon: SvgPicture.asset('assets/images/icon_role.svg'),
        ),
      ],
    );

    return AppScaffold(
      // (Phase 3) หน้านี้เป็นรูปทรงเฉพาะตัว ไม่เข้าพวก form/list/dashboard —
      // 2 คอลัมน์กว้างรวม ~900 ตาม PHASE3_PAGE_DESIGN.md หัวข้อ /profile
      maxWidth: 900,
      header: Header.mainHeader(
        context,
          title: 'ข้อมูลผู้ใช้งาน',
          subTitle: 'User Profile',
          iconPath: 'icon_profile.svg'
      ),
      content: Container(
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
                            child: Builder(builder: (context) {
                              // 🚩 (Phase 3) เดิม: การ์ดรูปกว้างเต็ม 1100 สูงแค่ ~70
                              // มีแค่วงกลมอักษรย่อเล็กๆ ชิดซ้าย ที่เหลือขาวโล่งทั้งการ์ด
                              // (ดู PHASE3_PAGE_DESIGN.md หัวข้อ /profile) บนจอกว้าง
                              // (มี sidebar) เปลี่ยนเป็น 2 คอลัมน์: ซ้ายการ์ดรูป+ชื่อ+
                              // ตำแหน่งแนวตั้ง ขวาฟิลด์/role เดิม — มือถือ/แท็บเล็ตแนวตั้ง
                              // คงพฤติกรรมเดิมทุกอย่าง
                              final wide = Responsive.showSidebar(context);

                              if (!wide) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 13,
                                  children: [
                                    SeparatorCard(
                                        separatorPadding: EdgeInsets.only(left: 45, right: 15),
                                        children: [
                                          ProfileButton(
                                            disable: true,
                                            icon: Image.network(
                                              profile!.avatarUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/images/profile.png',
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                            title: profile!.thName,
                                            subTitle: profile!.enName,
                                          ),
                                        ]
                                    ),
                                    fieldsCard,
                                    roleCard,
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16,
                                children: [
                                  SizedBox(
                                    width: 280,
                                    child: _WidePhotoCard(profile: profile!),
                                  ),
                                  Expanded(
                                    child: Column(
                                      spacing: 13,
                                      children: [fieldsCard, roleCard],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          )
                      )
                    ]
                )
            )
      )
    );
  }
}

/// การ์ดรูป+ชื่อ+ตำแหน่งแนวตั้ง — เฉพาะจอกว้างที่มี sidebar (ดู [_ProfilePageState])
class _WidePhotoCard extends StatelessWidget {
  final ProfileModel profile;

  const _WidePhotoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.shadowColor),
            child: Image.network(
              profile.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/profile.png',
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Text(
            profile.thName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.blackTextColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            profile.enName,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.lightTextColor),
          ),
          if (profile.roles.isNotEmpty) ...[
            SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: profile.roles.map((r) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: r.color.withAlpha((20 * 255 / 100).toInt()),
                  ),
                  child: Text(
                    r.name as String,
                    style: TextStyle(color: r.color, fontSize: 11),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
