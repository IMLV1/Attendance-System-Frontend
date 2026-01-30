import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

// import '../../shared/widgets/utils/clock_realtime.dart';
import '../../shared/widgets/utils/icon_text_button.dart';
import '../../shared/widgets/utils/separator_card.dart';

class CheckinPage extends StatefulWidget {
  const CheckinPage({super.key});

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}
class _CheckinPageState extends State<CheckinPage>{
  String currentTime = "18:30";
  String currentDay = "วันพฤหัสบดีที่ 29 มกราคม 2569";

  bool _hasCheckedIn = false;
  bool isDisabled = false;
  bool hasCheckedOut = false;

  bool _isAfterCheckoutTime(String currentTimeStr) {
    List<String> parts = currentTimeStr.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return (hour > 16 || (hour == 16 && minute >= 30));


  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return AppScaffold(
      hideNavigation: false,
      header: Header.mainHeader(
        context,
        title: 'ลงเวลาปฏิบัติงาน',
        subTitle: 'Time Attendance',
        iconPath: 'checkin_title_logo.svg'
      ),
      content: SafeArea(
          child : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    _cardtime(),
                    SizedBox(height: 20),
                    _buttonCheckin(),
                    SizedBox(height: 10),
                    _currentstate(),
                    SizedBox(height: 10),
                    SeparatorCard(
                      separatorPadding: EdgeInsets.all(10),
                      children: [
                        IconTextButton(icon:'icon_attendance_history.svg' , label:'ดูบันทึกการเข้า-ออกงาน' )
                      ],
                    )
                  ]
              )
          )
      ),
    );
  }

  Widget _cardtime () {
    return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 15,
                width: 15,
                child: SvgPicture.asset(
                    'assets/images/clock.svg'
                ),
              ),
              SizedBox(width: 7),
              Text(
                'เวลาปัจจุบัน',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.unSelectMenuColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child:Column(
                children: [
                  // const ClockWidget(),
                  Text(
                    currentTime,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.unSelectMenuColor,
                    ),
                  ),
                  Text(
                    currentDay,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextColor,
                    ),
                  )
                ],
              )
          )
        ]
    );
  }

  Widget _buttonCheckin () {

    bool isTimeout = _isAfterCheckoutTime(currentTime);

    Color buttonColor,backgroundbottom;
    String buttonText;
    String iconPath;
    double fontSize ;


    if (hasCheckedOut) {

      buttonColor = AppColors.buttondisable;
      backgroundbottom = AppColors.buttondisable_background;
      buttonText = "จบเวลางาน";
      iconPath = 'assets/images/endwork.svg';
      fontSize = 27;
      isDisabled = true;
    }
    else if (isTimeout) {

      buttonColor = AppColors.buttoncheckout;
      backgroundbottom = AppColors.buttoncheckout_background;
      buttonText = "เช็คเอาต์";
      iconPath = 'assets/images/click_checkin.svg';
      fontSize = 32;
      isDisabled = false;
    }
    else if (_hasCheckedIn) {

      buttonColor = AppColors.buttondisable;
      backgroundbottom = AppColors.buttondisable_background;
      buttonText = "อยู่ในเวลางาน";
      iconPath = 'assets/images/intimejob.svg';
      fontSize = 26;
      isDisabled = true;
    }
    else {
      buttonColor = AppColors.buttoncheckin;
      backgroundbottom = AppColors.buttoncheckin_background;
      buttonText = "เช็คอิน";
      iconPath = 'assets/images/click_checkin.svg';
      fontSize = 32;
      isDisabled = false;
    }
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
                padding: EdgeInsets.only(top: 210),
                child : Container(
                  width: 160,
                  height: 15,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightTextColor.withOpacity(0.2),
                        blurRadius: 1,
                        spreadRadius: 2,
                      )
                    ],
                    borderRadius: BorderRadius.all(Radius.elliptical(150, 15)),
                  ),
                )
            ),
            Material(
              color: Colors.transparent,
              child : InkWell(
                  onTap: isDisabled ? null : () {
                    setState(() {
                      if (isTimeout) {
                        hasCheckedOut = true; // กดตอนเย็น
                      } else {
                        _hasCheckedIn = true; // กดตอนเช้า
                      }
                    });
                    debugPrint("บันทึกสำเร็จ");
                  },
                  customBorder: CircleBorder(),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        color: buttonColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: backgroundbottom, width: 12,
                        )
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: SvgPicture.asset(
                            iconPath,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.titleColor,
                          ),
                        )
                      ],
                    ),
                  )
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          'กรุณากดปุ่มเพื่อ "เช็คอิน" เพื่อลงชื่อเข้างาน',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w200,
            color: AppColors.greyTextColor,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 17,
              width: 17,
              child: SvgPicture.asset(
                  'assets/images/iicon.svg'
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'กรุณาเช็คอินเข้างานภายในเวลา 08:30 หากเช็คอินเกินเวลาจะถือเป็นการเข้างานสาย ระบบจะทำการตัดรอบเวลา 00:00 ของทุกวัน ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: AppColors.lightTextColor,
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _currentstate () {
    return Container(
      width: double.infinity,
      padding:const EdgeInsets.all(16) ,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(
                    'assets/images/iicon.svg'
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'สถานะปัจจุบัน',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              )
            ],
          ),
          const SizedBox(height: 5),
          SeparatorCard(
            children: [
              _buildStatusItem(iconPath: 'assets/images/in.svg', title: 'เช็คอิน', time: _hasCheckedIn ? currentTime : "---"),
              _buildStatusItem(iconPath: 'assets/images/out.svg', title: 'เช็คเอาท์', time:hasCheckedOut ? currentTime : '---'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String iconPath,
    required String title,
    required String time
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              // ไอคอน
              SizedBox(
                height: 24,
                width: 24,
                child: SvgPicture.asset(iconPath),
              ),
              const SizedBox(width: 12),
              // ข้อความหัวข้อ
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // เวลา หรือ ขีดๆ ---
              Text(
                time,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greyTextColor,
                ),
              ),
            ],
          ),
        ),
        // เส้นคั่น (แสดงเฉพาะแถวที่ไม่ใช่แถวสุดท้าย)
      ],
    );
  }
}
