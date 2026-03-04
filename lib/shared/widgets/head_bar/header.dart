import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class Header {

  static AppBar subHeader(BuildContext context, {title = 'Default Title', VoidCallback? onBack}) {

    final width = MediaQuery
        .of(context)
        .size
        .width;

    double scaleFactor;

    if (width < 600) {
      scaleFactor = 1.0; // mobile
    } else if (width < 1200) {
      scaleFactor = 1.2; // tablet
    } else {
      scaleFactor = 1.4; // desktop
    }

    return AppBar(
      backgroundColor: AppColors.barColor,
      elevation: 0,

      leadingWidth: 56,

      toolbarHeight: 40 * scaleFactor,

      centerTitle: true,

      automaticallyImplyLeading: false,

      leading: Navigator.of(context).canPop() ?
      IconButton(
        onPressed: onBack ?? () {
          Navigator.of(context).pop();
        },
        icon: SvgPicture.asset(
          'assets/images/back_button.svg',
          width: 24 * scaleFactor,
          height: 24 * scaleFactor,
        ),
      ) : context.canPop() ? IconButton(
        onPressed: () {
          context.pop();
        },
        icon: SvgPicture.asset(
          'assets/images/back_button.svg',
          width: 24 * scaleFactor,
          height: 24 * scaleFactor,
        ),
      ) : null,

      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.titleColor,
        ),
      ),
    );
  }

  static AppBar mainHeader(BuildContext context, {title = 'Default Title', subTitle = 'Default SubTitle', iconPath = 'google_logo.svg', iconColor = Colors.white,String? firstTabText, String? firstTabRoute, String? secondTabText, String? secondTabRoute,}) {

    final width = MediaQuery
        .of(context)
        .size
        .width;

    double scaleFactor;

    if (width < 600) {
      scaleFactor = 1.0; // mobile
    } else if (width < 1200) {
      scaleFactor = 1.2; // tablet
    } else {
      scaleFactor = 1.4; // desktop
    }

    return AppBar(
      backgroundColor: AppColors.barColor,
      elevation: 0,

      /// ความสูง header
      toolbarHeight: 65 * scaleFactor,

      automaticallyImplyLeading: false,

      leadingWidth: double.infinity,
      leading: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Row(
          children: [
            Container(
              width: 40 * scaleFactor,
              height: 40 * scaleFactor,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.barHighlightColor,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/$iconPath',
                  width: 28 * scaleFactor,
                  height: 28 * scaleFactor,
                  colorFilter: ColorFilter.mode(
                    iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.titleColor,
                  ),
                ),
                Text(
                  subTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subTitleColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      /// RIGHT SIDE (actions)
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/images/notification.svg',
                  width: 26,
                  height: 26,
                ),
              ),
              if (Responsive.isMobile(context)) IconButton(
                onPressed: () {
                  context.pushNamed(RouteNames.setting);
                },
                icon: SvgPicture.asset(
                  'assets/images/hamburger_menu.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
