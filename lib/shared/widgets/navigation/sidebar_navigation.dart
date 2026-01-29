import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SideBarNavigation extends StatelessWidget {

  final String currentPath;

  const SideBarNavigation({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {

    int permissionLevel = 3;

    return SizedBox(

      width: 300,
      child: Scaffold(
        backgroundColor: AppColors.sideBarColor,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.sideBarColor,


          // 🔹 HEADER LOGO
          title: Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              'assets/images/engineering_logo.svg',
              height: 50,
            ),
          ),

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.lightTextColor,
            ),
          ),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,

          children: [
            const SizedBox(height: 15),
            SideBarButton(currentPath: currentPath, path: '/check-in', pageName: 'ลงชื่อเข้า-ออกงาน', pageIcon: 'icon_checkin.svg'),
            SideBarButton(currentPath: currentPath, path: '/time-request', pageName: 'ขออนุมัติเวลาเข้า-ออกงาน', pageIcon: 'icon_time_request.svg'),
            SideBarButton(currentPath: currentPath, path: '/leave', pageName: 'การลางาน', pageIcon: 'icon_leave.svg'),
            SideBarButton(currentPath: currentPath, path: '/statistic', pageName: 'สถิติ', pageIcon: 'icon_statistic.svg'),
            const SizedBox(height: 10),
            Divider(
              height: 1,        // space the divider takes vertically
              thickness: 1,     // actual line thickness
              color: AppColors.lightTextColor,
            ),
            const SizedBox(height: 10),
            SideBarButton(currentPath: currentPath, path: '/attendance-history', pageName: 'บันทึกการเข้างาน', pageIcon: 'icon_attendance_history.svg'),
            SideBarButton(currentPath: currentPath, path: '/leave-history', pageName: 'บันทึกการลางาน', pageIcon: 'icon_leave_history.svg'),
            SideBarButton(currentPath: currentPath, path: '/time-request-history', pageName: 'บันทึกคำขออนุมัติเวลางาน', pageIcon: 'icon_attendance_request_history.svg'),
            if (permissionLevel >= 1) const SizedBox(height: 10),
            if (permissionLevel >= 1) Divider(
              height: 1,        // space the divider takes vertically
              thickness: 1,     // actual line thickness
              color: AppColors.lightTextColor,
            ),
            if (permissionLevel >= 1) const SizedBox(height: 10),
            if (permissionLevel >= 1) SideBarButton(currentPath: currentPath, path: '/approval', pageName: 'อนุมัติคำขอ', pageIcon: 'icon_approval.svg'),
            if (permissionLevel >= 1) SideBarButton(currentPath: currentPath, path: '/approval-history', pageName: 'บันทึกการอนุมัติคำขอ', pageIcon: 'icon_attendance_history.svg'),
            if (permissionLevel >= 1) SideBarButton(currentPath: currentPath, path: '/personnel-info', pageName: 'ข้อมูลบุคลากรในองค์กร', pageIcon: 'icon_personnel_info.svg'),
            if (permissionLevel >= 2) const SizedBox(height: 10),
            if (permissionLevel >= 2) Divider(
              height: 1,        // space the divider takes vertically
              thickness: 1,     // actual line thickness
              color: AppColors.lightTextColor,
            ),
            if (permissionLevel >= 2) const SizedBox(height: 10),
            if (permissionLevel >= 2) SideBarButton(currentPath: currentPath, path: '/user-management', pageName: 'จัดการผู้ใช้งานระบบ', pageIcon: 'icon_user_management.svg'),
            if (permissionLevel >= 2) SideBarButton(currentPath: currentPath, path: '/role-management', pageName: 'จัดการตำแหน่ง', pageIcon: 'icon_role_management.svg'),
            if (permissionLevel >= 3) const SizedBox(height: 10),
            if (permissionLevel >= 3) Divider(
              height: 1,        // space the divider takes vertically
              thickness: 1,     // actual line thickness
              color: AppColors.lightTextColor,
            ),
            if (permissionLevel >= 3) const SizedBox(height: 10),
            if (permissionLevel >= 3) SideBarButton(currentPath: currentPath, path: '/settings/budget-year', pageName: 'ตั้งค่าปีงบประมาณ', pageIcon: 'icon_setting.svg'),
            if (permissionLevel >= 3) SideBarButton(currentPath: currentPath, path: '/settings/config-attendance', pageName: 'การลงชื่อเข้า-ออกงาน', pageIcon: 'icon_setting.svg'),
            if (permissionLevel >= 3) SideBarButton(currentPath: currentPath, path: '/settings/config-attendance-request', pageName: 'คำขออนุมัติเวลางาน', pageIcon: 'icon_setting.svg'),
            if (permissionLevel >= 3) SideBarButton(currentPath: currentPath, path: '/settings/config-leave-type', pageName: 'ประเภทการลางาน', pageIcon: 'icon_setting.svg'),
          ],
        ),
        bottomNavigationBar: Container(
          height: 100,
          decoration: BoxDecoration(
            border: BoxBorder.all(
              color: AppColors.lightTextColor,
              strokeAlign: BorderSide.strokeAlignOutside
            )
          ),

          child: Row(
            children: [
              Text(
                'PROFILE HERE',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 30
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}

class SideBarButton extends StatelessWidget {

  final String path;
  final String pageName;
  final String pageIcon;
  final String currentPath;

  const SideBarButton({super.key, required this.currentPath, required this.path, required this.pageName, required this.pageIcon});

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(

        onPressed: () {
          context.go(path);
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: currentPath == path ? AppColors.barColor : AppColors.sideBarColor,
          foregroundColor: currentPath == path ? AppColors.titleColor : AppColors.subTitleColor,
          padding: EdgeInsets.all(20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          elevation: 0,
        ),
        // width: double.infinity,
        // height: 60,
        child: Row(
          children: [
            SizedBox(width: 5),
            SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                'assets/images/$pageIcon',
                colorFilter: ColorFilter.mode(currentPath == path ? AppColors.titleColor : AppColors.subTitleColor, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: 10),
            Text(
                pageName,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal
                )
            )
          ],
        )
    );
  }

}