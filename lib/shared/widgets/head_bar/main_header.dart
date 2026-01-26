import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainHeader extends Header {
  final String subTitle;
  final String iconPath;

  const MainHeader({
    super.key,
    this.subTitle = 'Default SubTitle',
    this.iconPath = 'google_logo.svg',
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: AppColors.barColor,
        elevation: 0,

        /// ความสูง header
        toolbarHeight: 65,

        /// ❗ อย่าให้ AppBar เดา leading เอง
        automaticallyImplyLeading: false,

        /// LEFT SIDE (logo + title)
        leadingWidth: 260,
        leading: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.barHighlightColor,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/$iconPath',
                    width: 28,
                    height: 28,
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
            padding: const EdgeInsets.only(right: 25),
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
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () {},
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
      ),
    );
  }
}
