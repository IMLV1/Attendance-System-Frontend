import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/navigation/navigation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SideBarNavigation extends StatelessWidget {

  const SideBarNavigation({super.key});

  @override
  Widget build(BuildContext context) {

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
        body: Column(
          children: [
            const SizedBox(height: 15),
            SideBarButton(pageID: 'checkin', pageName: 'ลงชื่อเข้า-ออกงาน', pageIcon: 'icon_checkin.svg'),
            SideBarButton(pageID: 'time-request', pageName: 'ขออนุมัติเวลาเข้า-ออกงาน', pageIcon: 'icon_time_request.svg'),
            SideBarButton(pageID: 'leave', pageName: 'การลางาน', pageIcon: 'icon_leave.svg'),
            SideBarButton(pageID: 'statistic', pageName: 'สถิติ', pageIcon: 'icon_statistic.svg'),
            const SizedBox(height: 15),
            Divider(
              height: 1,        // space the divider takes vertically
              thickness: 1,     // actual line thickness
              color: AppColors.lightTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class SideBarButton extends StatelessWidget {

  final String pageID;
  final String pageName;
  final String pageIcon;

  const SideBarButton({super.key, required this.pageID, required this.pageName, required this.pageIcon});

  @override
  Widget build(BuildContext context) {

    NavigationState nav = context.watch<NavigationState>();
    String state = nav.currentPage;

    return ElevatedButton(

        onPressed: () {
          nav.setPage(pageID);
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: state == pageID ? AppColors.barColor : AppColors.sideBarColor,
          foregroundColor: state == pageID ? AppColors.titleColor : AppColors.subTitleColor,
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
            SizedBox(width: 15),
            SvgPicture.asset(
              'assets/images/$pageIcon',
              height: 30,
              colorFilter: ColorFilter.mode(state == pageID ? AppColors.titleColor : AppColors.subTitleColor, BlendMode.srcIn),
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