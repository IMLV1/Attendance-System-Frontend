import 'package:attendance_system/shared/theme/app_colors.dart';
import 'dart:async';

import 'package:attendance_system/services/personnel_info/personnel_info_model.dart';
import 'package:attendance_system/services/personnel_info/personnel_info_service.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChoosePersonnel extends StatefulWidget {

  final void Function(PersonnelInfoModel personnel) onChoose;

  const ChoosePersonnel({super.key, required this.onChoose});

  @override
  State<StatefulWidget> createState() => _ChoosePersonnelState();

}

class _ChoosePersonnelState extends State<ChoosePersonnel> {

  final TextEditingController _controller = TextEditingController();

  List<PersonnelInfoModel> personnel = [];
  List<PersonnelInfoModel> filteredPersonnel = [];

  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final input = query.toLowerCase();

      setState(() {
        if (input.isEmpty) {
          filteredPersonnel = personnel;
        } else {
          filteredPersonnel = personnel.where((user) {
            final nameTh = user.nameTH.toLowerCase();
            final nameEn = user.nameEN.toLowerCase();

            final roleMatch = user.roles.any((role) =>
              role.name.toLowerCase().contains(input));

            final initRole = user.initRole.toLowerCase();

            return nameTh.contains(input) ||
                nameEn.contains(input) ||
                roleMatch ||
                initRole.contains(input);
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 13,
      children: [
        TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(
                color: Color(0xFF7D7D7D), // 👈 สีตอนปกติ
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(
                color: Color(0xFF7D7D7D), // 👈 สีตอนปกติ
                width: 1,
              ),
            ),
            hint: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                SvgPicture.asset(
                  'assets/images/search.svg',
                  width: 15,
                  height: 15,
                ),
                Text(
                  'ค้นหาบุคลากร...',
                  style: TextStyle(
                    color: Color(0xFF7D7D7D),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        ServiceLoader(
          request: () => PersonnelInfoService().getPersonnelList(),
          onSuccess: (jsonData) {
            setState(() {
              personnel = PersonnelInfoModel.getList(jsonData);
              filteredPersonnel = personnel;

              filteredPersonnel.sort((a, b) {
                return compareNatural(a.nameTH, b.nameTH);
              });
            });
          },
          builder: () {
            // 🚩 (2026-08-22) ListView.builder — เดิมสร้างปุ่มของบุคลากรทุกคนพร้อมกัน
            // (แต่ละปุ่มมี Image.network ด้วย) องค์กรใหญ่ๆ เป็นร้อยคนจะกระตุกตอนเปิด
            // ตอนนี้สร้างเฉพาะที่อยู่ในจอ
            //
            // SeparatorCard ใช้กับ builder ไม่ได้ (ต้องรู้จำนวนลูกทั้งหมดเพื่อวาดเส้นคั่น
            // + มุมโค้ง) เลยจัดเองรายตัวให้หน้าตาเหมือนเดิม
            return Expanded(
              child: ListView.builder(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: filteredPersonnel.length,
                itemBuilder: (context, index) {
                  final m = filteredPersonnel[index];
                  final isFirst = index == 0;
                  final isLast = index == filteredPersonnel.length - 1;

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(isFirst ? 25 : 0),
                        bottom: Radius.circular(isLast ? 25 : 0),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        UserInfoButton(
                          icon: Image.network(
                            m.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Image.asset('assets/images/profile.png'),
                          ),
                          title: m.nameTH,
                          subTitle: m.nameEN,
                          roles: [
                            ...m.roles,
                            Role(id: '0000000000', name: m.initRole, color: const Color(0xFF535353)),
                          ],
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onChoose(m);
                          },
                        ),
                        if (!isLast)
                          const Padding(
                            padding: EdgeInsets.only(left: 65, right: 15),
                            child: Divider(height: 0),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        )
      ],
    );
  }
}

// Utils.mockResponse(data: {'data': [
// {
// 'id': '1100000000000',
// 'name-th': 'ศ.ดร.ด้วยดี ตามไท',
// 'name-en': 'Prof. Dr. Duaydee Tamtai',
// 'avatar-url': 'https://i.pinimg.com/736x/c0/05/11/c005114aae03691b32012e18c7ef3a6e.jpg',
// 'initial-role': 'วิศวกรรมคอมพิวเตอร์',
// 'roles': [
// {'role-id': '0000000001', 'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
// ]
// },
// {
// 'id': '1100000000001',
// 'name-th': 'ศ.ดร.ด้วยดี ตามไท',
// 'name-en': 'Prof. Dr. Duaydee Tamtai',
// 'avatar-url': 'https://i.pinimg.com/736x/c0/05/11/c005114aae03691b32012e18c7ef3a6e.jpg',
// 'initial-role': 'วิศวกรรมคอมพิวเตอร์',
// 'roles': [
// {'role-id': '0000000002', 'role-name': 'รองคณบดี', 'role-color': 'FFA51D'}
// ]
// },
// {
// 'id': '1100000000002',
// 'name-th': 'ศ.ดร.ด้วยดี ตามไท',
// 'name-en': 'Prof. Dr. Duaydee Tamtai',
// 'avatar-url': 'https://i.pinimg.com/736x/c0/05/11/c005114aae03691b32012e18c7ef3a6e.jpg',
// 'initial-role': 'วิศวกรรมคอมพิวเตอร์',
// 'roles': [],
// },
// ]}),