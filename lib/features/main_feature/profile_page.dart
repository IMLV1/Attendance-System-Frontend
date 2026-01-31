import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/cupertino.dart';

import '../../services/profile_page/profile_model.dart';

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
          "role_color": "#FF0000"
        },
        {
          "role_name": "คนสวน",
          "role_color": "#FF21343"
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
  final MockProfile _mockProfile = MockProfile();

  late Future<ProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _mockProfile.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.mainHeader(
        context,
          title: 'ข้อมูลผู้ใช้งาน',
          subTitle: 'User Profile',
          // iconPath: ''
      ),
      content: Row(

      ),
    );
  }
}