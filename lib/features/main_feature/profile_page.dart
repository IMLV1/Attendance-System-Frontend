import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/profile_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_role_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_value_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      "role_sys": [
        {
          "role_name": "คณบดี",
          "role_color": "FF0000"
        },
        {
          "role_name": "คนสวน",
          "role_color": "FF21343"
        }
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

  ProfileModel? _profileData; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await MockProfile().getProfile();
    setState(() {
      _profileData = data; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileData;

    if (profile == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return AppScaffold(
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
                            icon: Image.network(profile.avatarUrl, fit: BoxFit.cover), 
                            title: profile.thName, 
                            subTitle: profile.enName,
                          )
                        ]
                      ),
                      SeparatorCard(
                        separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 15),
                        children: [
                          TextValueButton(
                            // color: Color(0xFF949494),
                            disable: true,
                            label: 'รหัสบุคลากร', 
                            value: profile.staffId
                          ),
                          TextValueButton(
                            // color: Color(0xFF949494),
                            disable: true,
                            label: 'เลขบัตรประจำตัวประชาชน', 
                            value: profile.citizenId
                          ),
                          TextValueButton(
                            // color: Color(0xFF949494),
                            disable: true,
                            label: 'ชื่อ-นามสกุล', 
                            value: profile.thName
                          ),
                          TextValueButton(
                            // color: Color(0xFF949494),
                            disable: true,
                            label: 'Full-name', 
                            value: profile.enName
                          ),
                          TextValueButton(
                            // color: Color(0xFF949494),
                            disable: true,
                            label: 'เพศ', 
                            value: profile.gender
                          ),
                          TextValueButton(
                            // color: Color(0xFF949494),
                            disable: true,
                            label: 'สัญชาติ', 
                            value: profile.nationality
                          ),
                          TextValueButton(
                            // color: Color(0xFF949494),
                            disable: true,
                            label: 'เบอร์โทร', 
                            value: profile.phone
                          ),
                          TextValueButton(
                            // color: Color(0xFF949494),
                            disable: true,
                            label: 'อีเมล', 
                            value: profile.email
                          ),
                        ],
                      ),
                      // SeparatorCard(
                      //   children: [
                      //     TextRoleButton(
                      //       disable: true,
                      //       label: 'ตำแหน่งปัจจุบัน', 
                      //       roles: profile.roles, 
                      //       icon: SvgPicture.asset('assets/images/icon_role.svg'),
                      //     )
                      //   ],
                      // )
                    ],
                  ),
                )
              )
            ]
          )
        )
      )
    );
  }
}