import 'package:attendance_system/core/data/entities/profile_model.dart';
import 'package:attendance_system/core/data/provider/profile_provider.dart';
import 'package:attendance_system/core/data/repositories/profile_repository.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/profile_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_role_button.dart';
import 'package:attendance_system/shared/widgets/utils/text_value_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/utils/separator_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  ProfileModel? profile;

  @override
  Widget build(BuildContext context) {

    profile = context.watch<ProfileProvider>().profile;

    return AppScaffold(
      header: Header.mainHeader(
        context,
        title: 'ข้อมูลผู้ใช้งาน',
        subTitle: 'User Profile',
        iconPath: 'icon_profile.svg',
      ),
      content: Container(
        color: AppColors.backgroundColor,
        child: profile == null
                ? const Center(child: CupertinoActivityIndicator())
                : CustomScrollView(
              // ใส่ BouncingScrollPhysics เพื่อให้ดึงเด้งๆ สไตล์ iOS ได้เสมอแม้ข้อมูลไม่ล้นจอ
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // 1. พระเอกของเรา: Cupertino Refresh
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    await context.read<ProfileProvider>().load(forceRefresh: true);
                  },
                ),

                // 2. ใช้ SliverPadding แทน padding เดิมของ SingleChildScrollView
                SliverPadding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                  // 3. ใช้ SliverToBoxAdapter ครอบ Column โครงสร้าง UI เดิมของคุณ
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 13,
                      children: [
                        SeparatorCard(
                          separatorPadding: const EdgeInsets.only(left: 45, right: 15),
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
                          ],
                        ),
                        SeparatorCard(
                          separatorPadding: const EdgeInsets.only(right: 15, left: 15),
                          children: [
                            TextValueButton(
                              disable: true,
                              label: 'รหัสบุคลากร',
                              value: profile!.staffId,
                            ),
                            TextValueButton(
                              disable: true,
                              label: 'เลขบัตรประจำตัวประชาชน',
                              value: profile!.citizenId,
                            ),
                            TextValueButton(
                              disable: true,
                              label: 'ชื่อ-นามสกุล',
                              value: profile!.thName,
                            ),
                            TextValueButton(
                              disable: true,
                              label: 'Full-name',
                              value: profile!.enName,
                            ),
                            TextValueButton(
                              disable: true,
                              label: 'เพศ',
                              value: profile!.gender,
                            ),
                            TextValueButton(
                              disable: true,
                              label: 'สัญชาติ',
                              value: profile!.nationality,
                            ),
                            TextValueButton(
                              disable: true,
                              label: 'เบอร์โทร',
                              value: profile!.phone,
                            ),
                            TextValueButton(
                              disable: true,
                              label: 'อีเมล',
                              value: profile!.email,
                            ),
                          ],
                        ),
                        SeparatorCard(
                          children: [
                            TextRoleButton(
                              disable: true,
                              label: 'ตำแหน่งปัจจุบัน',
                              roles: profile!.roles,
                              icon: SvgPicture.asset('assets/images/icon_role.svg'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
        )
      ),
    );
  }
}