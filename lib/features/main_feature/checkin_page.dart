import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ntp/ntp.dart';

import '../../shared/widgets/utils/clock_realtime.dart';
import '../../shared/widgets/utils/radar_animation.dart';

import '../../shared/widgets/utils/icon_text_button.dart';
import '../../shared/widgets/utils/separator_card.dart';

import 'dart:async';
import 'package:intl/intl.dart';

class CheckinPage extends StatefulWidget {
  const CheckinPage({super.key});

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}
class _CheckinPageState extends State<CheckinPage>{

  DateTime? _currentNetworkTime;

  String checkInTimeRecorded = "---";
  String checkOutTimeRecorded = "---";

  bool _hasCheckedIn = false;
  bool isDisabled = false;
  bool hasCheckedOut = false;

  bool isOnLeave = false;          // ลางาน
  bool isPublicHoliday = false ;    // วันหยุดราชการ/นักขัตฤกษ์

  late Timer _timer;
  DateTime _lastResetDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _syncInitialTime(); // ซิงค์เวลาโลกครั้งแรก
  }

  Future<void> _syncInitialTime() async {
    try {
      _currentNetworkTime = await NTP.now(lookUpAddress: 'time.google.com');
    } catch (e) {
      _currentNetworkTime = DateTime.now(); // ถ้าเน็ตล่ม ให้ถอยไปใช้เวลาเครื่อง
    }

    // เริ่ม Timer ให้เดินวินาทีละครั้ง
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _currentNetworkTime != null) {
        setState(() {
          // บวกเวลาเพิ่ม 1 วินาทีในทุกๆ วินาทีที่ผ่านไป
          _currentNetworkTime = _currentNetworkTime!.add(const Duration(seconds: 1));
          _checkAndResetLogic();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // ล้าง Timer เพื่อประหยัด Memory
    super.dispose();
  }

  void _checkAndResetLogic() {
    final now = DateTime.now();
    // 1. Reset ทุกอย่างเมื่อถึงเวลา 08:30 ของวันใหม่
    // เช็คว่าชั่วโมงคือ 8, นาทีคือ 30 และยังไม่ได้ Reset ในวันนี้
    if (now.hour == 8 && now.minute == 30 && _lastResetDate.day != now.day) {
      _resetDailyData(now);
      debugPrint("--- TEST RESET WORKING ---");
    }
    // 2. หรือ Reset เมื่อผ่านเที่ยงคืน (กรณีแอปเปิดทิ้งไว้ข้ามคืน)
    else if (now.day != _lastResetDate.day && now.hour >= 0) {
      _resetDailyData(now);
    }
    // สั่ง Rebuild เพื่อให้ _getButtonState() ตรวจสอบเวลา 16:30 เพื่อเปลี่ยนปุ่ม
    if (mounted) setState(() {});
  }

  void _resetDailyData(DateTime now) {
    setState(() {
      checkInTimeRecorded = "---";
      checkOutTimeRecorded = "---";
      _hasCheckedIn = false;
      hasCheckedOut = false;
      _lastResetDate = now;
    });
    debugPrint("ระบบทำการ Reset ข้อมูลประจำวันเรียบร้อยแล้ว");
  }

  String _getButtonState() {
    final now = _currentNetworkTime!;
    final hour = now.hour;
    final minute = now.minute;

    // เช็ควันหยุดสุดสัปดาห์ (ใช้เวลาเน็ตเช็ควัน)
    if (hasCheckedOut) return "FINISHED";

    if (!_hasCheckedIn) return "CHECK_IN_READY";

    bool isAfterWork = hour > 16 || (hour == 16 && minute >= 30);
    if (isAfterWork) {
      return "CHECK_OUT_READY";
    }
    if (_hasCheckedIn) return "WORKING";
    return "CHECK_IN_READY";
  }

  bool _checkIsWeekend() {
    if(_currentNetworkTime == null) return false;
    int day = _currentNetworkTime!.weekday;
    return day == DateTime.saturday || day == DateTime.sunday;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNetworkTime == null) {
      return AppScaffold(
        header: Header.mainHeader(context, title: 'ลงเวลาปฏิบัติงาน'),
        content: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.buttonCheckIn),
              const SizedBox(height: 20),
              Text(
                "กำลังโหลดข้อมูล...",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.greyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _cardtime(),
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
                   const ClockWidget(),
                  // Text(
                  //   currentTime,
                  //   style: TextStyle(
                  //     fontSize: 40,
                  //     fontWeight: FontWeight.w700,
                  //     color: AppColors.unSelectMenuColor,
                  //   ),
                  // ),
                  // Text(
                  //   currentDay,
                  //   style: TextStyle(
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.w500,
                  //     color: AppColors.lightTextColor,
                  //   ),
                  // )
                ],
              )
          )
        ]
    );
  }

  Widget _buttonCheckin () {

    String state = _getButtonState(); // ดึงสถานะปัจจุบันตามเวลาจริง
    bool isWeekend = _checkIsWeekend();

    Color buttonColor;
    String buttonText;
    String iconPath;
    double fontSize ;
    bool isDisabled = false;

    if (isOnLeave) {
      buttonColor = AppColors.buttonDisable;
      buttonText = "ลางาน";
      iconPath = 'assets/images/leave.svg'; // เตรียมไอคอนลา
      isDisabled = true;
      fontSize = 27;
    }
    else if (isPublicHoliday) {
      buttonColor = AppColors.buttonDisable;
      buttonText = "วันหยุดราชการ";
      iconPath = 'assets/images/publicholiday.svg';
      isDisabled = true;
      fontSize = 24;
    }else if(isWeekend) {
      buttonColor = AppColors.buttonDisable;
      buttonText = "วันหยุด";
      iconPath = 'assets/images/weekend.svg'; // เตรียมไอคอนวันหยุดสุดสัปดาห์
      isDisabled = true;
      fontSize = 32;
    }
    else {
      switch (state) {
        case "FINISHED":
          buttonColor = AppColors.buttonDisable;
          buttonText = "จบเวลางาน";
          iconPath = 'assets/images/endwork.svg';
          isDisabled = true;
          fontSize = 27;

          break;
        case "CHECK_OUT_READY":
          buttonColor = AppColors.buttonCheckOut;
          buttonText = "เช็คเอาต์";
          iconPath = 'assets/images/click_checkin.svg';
          isDisabled = false;
          fontSize = 32;
          break;
        case "WORKING":
          buttonColor = AppColors.buttonDisable;
          buttonText = "อยู่ในเวลางาน";
          iconPath = 'assets/images/intimejob.svg';
          isDisabled = true;
          fontSize = 26;
          break;
        default: // CHECK_IN_READY
          buttonColor = AppColors.buttonCheckIn;
          buttonText = "เช็คอิน";
          iconPath = 'assets/images/click_checkin.svg';
          isDisabled = false;
          fontSize = 32;
      }
    }
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            RadarAnimation(color: buttonColor),
            Padding(
                padding: EdgeInsets.only(top: 270),
                child : Container(
                  width: 140,
                  height: 15,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightTextColor.withValues(alpha: 0.2),
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
                  onTap: isDisabled ? null : () async { // 1. เติม async ตรงนี้
                    try {
                      // 2. แสดง Loading หรือสั่นเล็กน้อยเพื่อบอกผู้ใช้ว่ากำลังประมวลผล
                      HapticFeedback.mediumImpact();

                      DateTime ntpTime = await NTP.now(lookUpAddress: 'time.google.com');

                      // 4. แปลงเวลา NTP ที่ได้เป็น Format ที่ต้องการ
                      String nowTime = DateFormat('HH:mm').format(ntpTime);

                      setState(() {
                        if (state == "CHECK_OUT_READY") {
                          checkOutTimeRecorded = nowTime; // บันทึกเวลาออกจริงจากเน็ต
                          hasCheckedOut = true;
                        } else {
                          checkInTimeRecorded = nowTime; // บันทึกเวลาเข้าจริงจากเน็ต
                          _hasCheckedIn = true;
                        }
                      });

                      debugPrint("บันทึกสำเร็จด้วยเวลา NTP: $nowTime");

                      // (เพิ่มเติม) คุณอาจจะโชว์ Dialog หรือ SnackBar ว่าบันทึกสำเร็จแล้ว
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('บันทึกเวลา $nowTime น. เรียบร้อยแล้ว')),
                      );

                    } catch (e) {
                      debugPrint("เกิดข้อผิดพลาด: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ไม่สามารถดึงเวลาจริงได้ กรุณาตรวจสอบอินเทอร์เน็ต'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  customBorder: CircleBorder(),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        color: buttonColor,
                        shape: BoxShape.circle,
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
              height: 15,
              width: 15,
              child: SvgPicture.asset(
                  'assets/images/iicon.svg'
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                softWrap: true,
                textAlign: TextAlign.start,
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
        color: Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                height: 15,
                width: 15,
                child: SvgPicture.asset(
                    'assets/images/i_icon.svg'
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
            separatorPadding: EdgeInsetsGeometry.only(left: 52, right: 10),
            children: [
              _buildStatusItem(iconPath: 'assets/images/in.svg', title: 'เช็คอิน', time: _hasCheckedIn ? checkInTimeRecorded : "---"),
              _buildStatusItem(iconPath: 'assets/images/out.svg', title: 'เช็คเอาท์', time:hasCheckedOut ? checkOutTimeRecorded : '---'),
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
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 20),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // // เวลา หรือ ขีดๆ ---
              Text(
                time,
                style: const TextStyle(
                  fontSize: 15,
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
