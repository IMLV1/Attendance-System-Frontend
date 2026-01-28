import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/navigation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class BottomNavigation extends StatelessWidget {

  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {

    return BottomAppBar(
      color: AppColors.cardColor,
      elevation: 8,
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.subTitleColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navigationItem(context, 'time-request', 'icon_time_request.svg', 'ขออนุมัติเวลา'),
            _navigationItem(context, 'leave', 'icon_leave.svg', 'ลางาน'),
            _centerItem(context, 'checkin', 'icon_checkin.svg', 'เข้า-ออกงาน'),
            _navigationItem(context, 'statistic', 'icon_statistic.svg', 'สถิติ'),
            _profileItem(context, 'profile', '', 'โปรไฟล์'),
          ],
        ),
      ),
    );
  }

  Widget _navigationItem(BuildContext context, String pageName, String iconPath, String label) {

    NavigationState nav = context.watch<NavigationState>();
    String currentState = nav.currentPage;

    return Expanded(
      child: InkWell(

        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,

        onTap: () {
          nav.setPage(pageName);
        },

        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 30,
              width: 30,
              child: SvgPicture.asset(
                'assets/images/$iconPath',
                colorFilter: ColorFilter.mode(currentState == pageName ? AppColors.selectedMenuColor : AppColors.unSelectMenuColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: (currentState == pageName) ? AppColors.selectedMenuColor : AppColors.unSelectMenuColor
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  Widget _centerItem(BuildContext context, String pageName, String iconPath, String label) {

    NavigationState nav = context.watch<NavigationState>();
    String currentState = nav.currentPage;

    return Expanded(
      child: InkWell(

        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,

        onTap: () {
          nav.setPage(pageName);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, 2),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: (currentState == pageName) ? AppColors.selectedMenuColor : AppColors.unSelectMenuIconColor,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/$iconPath',
                    width: 35,
                    height: 35,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 2),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: (currentState == pageName) ? AppColors.selectedMenuColor : AppColors.unSelectMenuIconColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _profileItem(BuildContext context, String pageName ,String iconPath, String label) {

    NavigationState nav = context.watch<NavigationState>();
    String currentState = nav.currentPage;

    return Expanded(
      child: InkWell(

        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,

        onTap: () {
          nav.setPage(pageName);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/$iconPath',
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: (currentState == pageName) ? AppColors.selectedMenuColor : AppColors.unSelectMenuColor, size: 35),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: (currentState == pageName) ? AppColors.selectedMenuColor : AppColors.unSelectMenuColor
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

}