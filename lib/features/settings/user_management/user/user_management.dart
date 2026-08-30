import 'dart:async';

import 'package:attendance_system/features/settings/role_management/role_management.dart';
import 'package:attendance_system/features/settings/user_management/user/create_user.dart';
import 'package:attendance_system/features/settings/user_management/user/user_info.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/services/user_management/user_management_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/master_detail_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<StatefulWidget> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {

  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<UserManagementModel> users = [];
  List<UserManagementModel> filteredUsers = [];

  /// ผู้ใช้ที่กำลังดูอยู่ในคอลัมน์ขวา — ใช้เฉพาะโหมด master-detail (จอกว้าง)
  /// บนมือถือยังกดแล้ว push หน้าใหม่เหมือนเดิม ค่านี้จึงเป็น null ตลอด
  UserManagementModel? selected;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final input = query.toLowerCase();

      setState(() {
        if (input.isEmpty) {
          filteredUsers = users;
        } else {
          filteredUsers = users.where((user) {
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

    // 🚩 (Phase 6, 2026-08-27) บนจอกว้างหน้านี้เคยเป็นรายการแคบๆ กลางจอ
    // กดชื่อแล้ว push ทับทั้งหน้าเพื่อดูข้อมูลคนเดียว ทั้งที่พื้นที่พอวางสอง
    // คอลัมน์ได้สบาย และการสลับดูทีละคนต้องกด back ทุกครั้ง
    if (!Responsive.isCompact(context)) return _masterDetail(context);

    return AppScaffold(
      maxWidth: Responsive.widthFor(ContentShape.list),
      header: Header.subHeader(context, title: 'จัดการผู้ใช้งานระบบ'),
      content: _body(context),
    );
  }

  Widget _masterDetail(BuildContext context) {
    final user = selected;

    return MasterDetailScaffold(
      title: 'จัดการผู้ใช้งานระบบ',
      emptyLabel: 'เลือกผู้ใช้จากรายการทางซ้าย',
      // กว้างกว่า 360 ของหน้าข้อมูลบุคลากร เพราะแถวนี้มี fallback เป็นอีเมล
      // เต็มๆ (บาง account ไม่มีชื่อ) ที่ 360 อีเมลตัดสามบรรทัดจนแถวสูงผิดปกติ
      masterWidth: 430,
      masterPadding: EdgeInsets.zero,
      master: _body(context),
      detail: user == null
          ? null
          // key ผูกกับ id — สลับคนแล้ว state เก่าหายไปเอง ไม่ต้องไล่เคลียร์
          : UserInfo(
              key: ValueKey(user.id),
              userInfo: user,
              embedded: true,
              onChanged: _replaceUser,
              onDeleted: () {
                setState(() {
                  users.remove(user);
                  selected = null;
                });
                _onSearchChanged(_controller.text);
              },
            ),
    );
  }

  void _replaceUser(UserManagementModel updated) {
    final index = users.indexWhere((u) => u.id == updated.id);
    setState(() {
      if (index >= 0) users[index] = updated;
      selected = updated;
    });
    _onSearchChanged(_controller.text);
  }

  Widget _body(BuildContext context) {
    return SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 13,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: AppColors.shadowColor,
                        ),
                        padding: EdgeInsets.only(top: 12, left: 10, right: 10, bottom: 8),

                        width: double.infinity,
                        child: Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: AppColors.titleColor,
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                height: 35,
                                width: 35,
                                padding: EdgeInsets.all(4),
                                child: SvgPicture.asset(
                                  'assets/images/role_management.svg',
                                )
                            ),

                            Expanded(child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 5,
                                  children: [
                                    Text(
                                      'จัดการตำแหน่งผู้ใช้งาน',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15
                                      ),
                                    ),
                                    Divider(height: 0),
                                    Text(
                                        'กำหนดและจัดการตำแหน่ง เพื่อควบคุมการเข้าถึง และกำหนดขอบเขตความรับผิดชอบของบทบาท',
                                        style: TextStyle(
                                            color: AppColors.lightTextColor,
                                            fontSize: 12,
                                            height: 1.3
                                        )
                                    )
                                  ],
                                ),
                                Container(
                                    width: double.infinity,
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          overlayColor: Colors.transparent,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => RoleManagement(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'ไปจัดการ',
                                          style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 14
                                          ),
                                        )
                                    )
                                )
                              ],
                            )),
                          ],
                        )
                    ),
                    Column(
                      spacing: 5,
                      children: [
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              spacing: 6,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/users.svg',
                                ),
                                Text('ผู้ใช้งาน')
                              ],
                            )
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: TextField(
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
                                          Text('ค้นหาผู้ใช้...',
                                              style: TextStyle(
                                                  color: Color(0xFF7D7D7D),
                                                  fontSize: 15
                                              )
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 55,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        UserManagementModel? updatedUser = await Navigator.of(context).push(
                                          MaterialPageRoute<UserManagementModel>(
                                            builder: (context) => CreateUser(),
                                          ),
                                        );

                                        if (updatedUser != null) {
                                          setState(() {
                                            users.add(updatedUser);
                                            _onSearchChanged(_controller.text);
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.all(0),
                                        side: const BorderSide(
                                          color: Color(0xFF7D7D7D),
                                          width: 1,
                                        ),
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/images/create_user.svg',
                                        colorFilter: ColorFilter.mode(Color(0xFF7D7D7D), BlendMode.srcIn),
                                      )
                                  ),
                                )
                              ],
                            )
                        )
                      ],
                    ),
                    Expanded(
                      child: ServiceLoader(
                        request: () => UserManagementService().getData(),
                        onSuccess: (jsonData) {
                          final List<UserManagementModel> data = UserManagementModel.getList(jsonData);

                          setState(() {
                            users = data;
                            _onSearchChanged(_controller.text);
                          });
                        },
                        // 🚩 (2026-08-22) ListView.builder — เดิมสร้างปุ่มผู้ใช้ทุกคนพร้อมกัน
                        // (แต่ละปุ่มมี Image.network) หน่วยงานที่มีคนเป็นร้อยจะกระตุกตอนเปิดหน้า
                        // SeparatorCard ใช้กับ builder ไม่ได้ เลยจัดเส้นคั่น/มุมโค้งเองรายตัว
                        builder: () => ListView.builder(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                              final m = filteredUsers[index];
                              final isFirst = index == 0;
                              final isLast = index == filteredUsers.length - 1;
                              // ไฮไลต์เฉพาะโหมด master-detail — จอแคบกดแล้วเปิด
                              // หน้าใหม่ทับไปเลย ไม่มีรายการค้างให้ต้องบอกว่าเลือกอะไรอยู่
                              final isSelected = !Responsive.isCompact(context) &&
                                  m.id == selected?.id;
                              return Container(
                                decoration: BoxDecoration(
                                  // ไฮไลต์คนที่กำลังดูอยู่ — จำเป็นเฉพาะโหมด
                                  // master-detail ที่รายการค้างอยู่ข้างๆ ตลอด
                                  color: isSelected
                                      ? const Color(0xFFEDE3E4)
                                      : AppColors.cardColor,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(isFirst ? 25 : 0),
                                    bottom: Radius.circular(isLast ? 25 : 0),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                UserInfoButton(
                                  onPressed: () async {
                                    // จอกว้าง: เปลี่ยนเนื้อหาคอลัมน์ขวาแทนการ
                                    // push ทับทั้งหน้า
                                    if (!Responsive.isCompact(context)) {
                                      setState(() => selected = m);
                                      return;
                                    }

                                    final ({int status, UserManagementModel? updatedUser})? res = await Navigator.of(context).push<({int status, UserManagementModel? updatedUser})>(
                                      MaterialPageRoute(
                                        builder: (context) => UserInfo(userInfo: m),
                                      ),
                                    );

                                    if (res != null) {

                                      if (res.status == 0) {
                                        final index = users.indexWhere((
                                            u) =>
                                        u.id == res.updatedUser!.id);
                                        setState(() {
                                          users[index] = res.updatedUser!;
                                        });
                                      } else if (res.status == 1) {
                                        setState(() {
                                          users.remove(m);
                                        });
                                      }
                                    }
                                  },
                                  icon: Image.network(
                                    m.avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/profile.png',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                  // 🚩 (Phase 3) บาง account (เช่น admin/system-root) ไม่มี
                                  // name-th/name-en จาก backend -> แถวว่างเปล่าไม่รู้ว่าเป็นใคร
                                  // fallback ไปที่ email แล้วค่อย employee-id ให้แถวไม่ว่างเปล่า
                                  title: m.nameTH.isNotEmpty
                                      ? m.nameTH
                                      : (m.email.isNotEmpty ? m.email : m.employeeId),
                                  subTitle: m.nameEN,
                                  roles: [...m.roles, Role(id: '0000000000', name: m.initRole, color: Color(0xFF535353))],
                                ),
                                    if (!isLast)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 70, right: 15),
                                        child: Divider(height: 0),
                                      ),
                                  ],
                                ),
                              );
                          },
                        ),
                      )

                      // child: users.isEmpty
                      //     ? const Center(child: CupertinoActivityIndicator())
                      //     : SingleChildScrollView(
                      //   physics: const AlwaysScrollableScrollPhysics(),
                      //   child: SeparatorCard(
                      //     separatorPadding: const EdgeInsets.only(left: 70, right: 15),
                      //     children: [
                      //       ...filteredUsers.map((m) {
                      //         return UserInfoButton(
                      //           onPressed: () async {
                      //             final updatedUser = await Navigator.of(context).push<UserManagementModel>(
                      //               MaterialPageRoute(
                      //                 builder: (context) => UserInfo(userInfo: m),
                      //               ),
                      //             );
                      //
                      //             if (updatedUser != null) {
                      //               final index = users.indexWhere((u) => u.id == updatedUser.id);
                      //
                      //               setState(() {
                      //                 users[index] = updatedUser;
                      //               });
                      //             }
                      //
                      //           },
                      //           icon: Image.network(
                      //             m.avatarUrl,
                      //             fit: BoxFit.cover,
                      //           ),
                      //           title: m.nameTH,
                      //           subTitle: m.nameEN,
                      //           roles: [...m.roles, Role(id: '0000000000', name: m.initRole, color: Color(0xFF535353))],
                      //         );
                      //       }),
                      //     ],
                      //   ),
                      // ),
                    )
                  ]
              )
          )
        )
    );
  }
}
