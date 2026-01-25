import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';

class Header extends StatelessWidget{
  final String titleThai;
  final String titleEng;
  final iconHamburger = Icons.menu;
  final iconNotification = Icons.notifications_none;
  final String iconPath ;
  const Header({
    super.key,
    this.titleThai = 'ลงเวลาปฏิบัติงาน',
    this.titleEng = 'Time Attendance',
    this.iconPath = 'checkin_title_logo.svg'
  });

  @override
  Widget build(BuildContext context){

    return Positioned(
      left: 0,
      right: 0,
      height: 125,
      child: AppBar(
        backgroundColor: AppColors.barColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 0,

        title: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                  spacing: 16,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.barHighlightColor
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/$iconPath',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleThai,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.titleColor
                          ),
                        ),
                        Text(
                          titleEng,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.subTitleColor
                          ),
                        )
                      ],
                    )
                  ]
              ),

              Padding(padding: EdgeInsetsGeometry.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.only(top: 3),
                      child: SvgPicture.asset(
                        'assets/images/notification.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/images/hamburger_menu.svg',
                      width: 25,
                      height: 25,
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    )
    );
  }
}
