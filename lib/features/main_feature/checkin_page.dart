import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_model.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';

import '../../services/check-in/check-in_model.dart';
import '../../services/check-in/check-in_service.dart';
import '../../services/check-in/holiday_service.dart';
import '../../shared/widgets/utils/clock_realtime.dart';
import '../../shared/widgets/utils/radar_animation.dart';

import '../../shared/widgets/utils/icon_text_button.dart';
import '../../shared/widgets/utils/separator_card.dart';

import 'dart:async';
import 'package:intl/intl.dart';

import '../../shared/widgets/utils/services/service_loader.dart';

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
  bool isPublicHoliday = false;    // วันหยุดราชการ/นักขัตฤกษ์

  ConfigAttendanceTimeModel? configSetting;

  Timer? _timer;
  DateTime _lastResetDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _syncInitialTime(); // ซิงค์เวลาโลกครั้งแรก
      _loadInitialState(DateTime.now());
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   final attendanceService = GetIt.I<AttendanceService>();
    //   await attendanceService.clearLocalState(); // สมมติว่ามีฟังก์ชันล้างข้อมูลใน Service
    //   debugPrint("🧹 ข้อมูลถูก Reset ใหม่ทั้งหมด (Build ใหม่)");
    // });

    initConfig();
  }
  // เพิ่มฟังก์ชันเหล่านี้ภายในคลาส _CheckinPageState

  Future<void> initConfig() async {
    try {
      final config = await ConfigAttendanceTimeService().getData();

      if (!mounted) return;

      setState(() {
        configSetting = ConfigAttendanceTimeModel.fromJson(config.data);
      });
    } catch (e) {
      debugPrint("ไม่สามารถโหลดการตั้งค่าเวลาได้: $e");
    }
  }

  Future<void> _loadInitialState(DateTime networkTime) async {
    final attendanceService = GetIt.I<AttendanceService>();

    // แก้ตรงนี้: ส่ง networkTime เข้าไปให้ Service เช็ควันที่ให้เบ็ดเสร็จ
    final savedState = await attendanceService.getLocalState(networkTime);

    if (savedState != null) {
      // ถ้า Service คืนค่ามา แสดงว่าเป็นของวันนี้แน่นอน
      setState(() {
        checkInTimeRecorded = savedState.checkInTime ?? "---";
        checkOutTimeRecorded = savedState.checkOutTime ?? "---";
        _hasCheckedIn = savedState.hasCheckedIn;
        hasCheckedOut = savedState.hasCheckedOut;
      });
    } else {
      // ถ้าคืน null แสดงว่าเป็นวันใหม่ หรือไม่มีข้อมูล
      setState(() {
        checkInTimeRecorded = "---";
        checkOutTimeRecorded = "---";
        _hasCheckedIn = false;
        hasCheckedOut = false;
      });
    }
  }

  Future<void> _saveCurrentState() async {
    if (_currentNetworkTime == null) return;

    final attendanceService = GetIt.I<AttendanceService>();
    final today = DateFormat('yyyy-MM-dd').format(_currentNetworkTime!);

    final attendanceData = AttendanceModel(
      checkInTime: checkInTimeRecorded,
      checkOutTime: checkOutTimeRecorded,
      hasCheckedIn: _hasCheckedIn,
      hasCheckedOut: hasCheckedOut,
      lastUpdateDate: today,
    );

    // 2. ใช้ attendanceData (ข้อมูล) ในการ Print และ Save
    debugPrint("กำลังบันทึกลง Local Storage: ${attendanceData.toJson()}");

    // 3. เรียก Service ให้บันทึก "ข้อมูล" ลงไป
    await attendanceService.saveLocalState(attendanceData);
  }

  Future<void> _syncInitialTime() async {
    try {
      _currentNetworkTime = await NTP.now(lookUpAddress: 'time.google.com');
    } catch (e) {
      _currentNetworkTime = DateTime.now(); // ถ้าเน็ตล่ม ให้ถอยไปใช้เวลาเครื่อง
    }

  }

  @override
  void dispose() {
    _timer?.cancel(); // ล้าง Timer เพื่อประหยัด Memory
    super.dispose();
  }

  void _checkAndResetLogic(ConfigAttendanceTimeModel? configSetting) {
    final now = DateTime.now();
    // 1. Reset ทุกอย่างเมื่อถึงเวลา 08:30 ของวันใหม่
    // เช็คว่าชั่วโมงคือ 8, นาทีคือ 30 และยังไม่ได้ Reset ในวันนี้
    //&& _lastResetDate.day != now.day
    if (configSetting?.cutoffTime.hour == now.hour && configSetting?.cutoffTime.minute == now.minute && _lastResetDate.day != now.day) {
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
    if (_currentNetworkTime == null) return "CHECK_IN_READY";

    final now = _currentNetworkTime!;
    final hour = now.hour;
    final minute = now.minute;

    bool isAfterWork = hour > configSetting!.checkOutTime.hour || (hour == configSetting!.checkOutTime.hour && minute >= configSetting!.checkOutTime.minute);

    if (hasCheckedOut) return "FINISHED";

    if (isAfterWork) {
      if (_hasCheckedIn) {
        return "CHECK_OUT_READY";
      } else {
        return "ABSENT";
      }
    }
    if (!_hasCheckedIn) return "CHECK_IN_READY";

    return "WORKING";
  }

  bool _checkIsWeekend() {
    if(_currentNetworkTime == null) return false;
    int day = _currentNetworkTime!.weekday;
    return day == DateTime.saturday || day == DateTime.sunday;
  }

  @override
  Widget build(BuildContext context) {
    // ConfigAttendanceTimeModel? configSetting = context.watch<AuthState>().timeConfig;

    return AppScaffold(
      hideNavigation: false,
      header: Header.mainHeader(
          context,
          title: 'ลงเวลาปฏิบัติงาน',
          subTitle: 'Time Attendance',
          iconPath: 'checkin_title_logo.svg'
      ),
      content: (configSetting == null)
      ? Center(child: CupertinoActivityIndicator(color: Colors.black))
      : ServiceLoader(
        request: () async {
          try {
            final time = await NTP.now(lookUpAddress: 'time.google.com');
            return Response(
              requestOptions: RequestOptions(path: ''),
              data: time,
              statusCode: 200,
            );
          } catch (e) {
            return Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 500,
              statusMessage: "ไม่สามารถเชื่อมต่อเวลาได้",
            );
          }
        },
        onSuccess: (data) async {
          if (_currentNetworkTime == null) {

            // 🔐 กัน null ก่อน
            if (data == null || data is! DateTime) {
              return; // ยังไม่มีเวลา ไม่ต้องทำอะไร
            }

            final DateTime ntpNow = data;   // ตอนนี้ non-null แน่นอน
            _currentNetworkTime = ntpNow;

            final holidayService = GetIt.I<HolidayService>();
            final bool holidayStatus =
            await holidayService.checkTodayIsHoliday(ntpNow);

            if (!mounted) return;

            setState(() {
              isPublicHoliday = holidayStatus;
            });

            // ไม่ต้องใช้ !
            await _loadInitialState(ntpNow);
            _startTimerLogic();
          }

        },
        builder: () => SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _cardtime(),
                _buttonCheckin(),
                const SizedBox(height: 10),
                _currentstate(),
                const SizedBox(height: 10),
                SeparatorCard(
                  separatorPadding: const EdgeInsets.all(10),
                  children: [
                    IconTextButton(
                        icon: 'icon_attendance_history.svg',
                        label: 'ดูบันทึกการเข้า-ออกงาน'
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

// แยกฟังก์ชันการเริ่ม Timer
  void _startTimerLogic() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _currentNetworkTime != null) {
        setState(() {
          _currentNetworkTime = _currentNetworkTime!.add(const Duration(seconds: 1));
          _checkAndResetLogic(configSetting);
        });
      }
    });
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
    String showtext;
    String iconPath;
    double fontSize ;
    bool isDisabled = false;

    if (isOnLeave) {
      buttonColor = AppColors.buttonDisable;
      buttonText = "ลางาน";
      showtext = 'ลางาน';
      iconPath = 'assets/images/leave.svg'; // เตรียมไอคอนลา
      isDisabled = true;
      fontSize = 27;
    }
    else if (isPublicHoliday) {
      buttonColor = AppColors.buttonDisable;
      buttonText = "วันหยุดราชการ";
      showtext ='วันหยุดราชการ';
      iconPath = 'assets/images/publicholiday.svg';
      isDisabled = true;
      fontSize = 24;
    }else if(isWeekend) {
      buttonColor = AppColors.buttonDisable;
      buttonText = "วันหยุด";
      showtext = 'วันหยุดสุดสัปดาห์';
      iconPath = 'assets/images/weekend.svg'; // เตรียมไอคอนวันหยุดสุดสัปดาห์
      isDisabled = true;
      fontSize = 32;
    }
    else {
      switch (state) {

        // case "ABSENT":
        //   buttonColor = AppColors.buttonDisable;
        //   buttonText = "ขาดงาน";
        //    showtext = 'ขาดงาน';
        //   iconPath = 'assets/images/absent.svg';
        //   isDisabled = true;
        //   fontSize = 27;
        //   break;

        case "FINISHED":
          buttonColor = AppColors.buttonDisable;
          buttonText = "จบเวลางาน";
          showtext = 'ยินดีด้วย! คุณทำงานเสร็จแล้ว';
          iconPath = 'assets/images/endwork.svg';
          isDisabled = true;
          fontSize = 27;

          break;
        case "CHECK_OUT_READY":
          buttonColor = AppColors.buttonCheckOut;
          buttonText = "เช็คเอาต์";
          showtext = 'กรุณากดปุ่ม “เช็คเอ้าท์” เพื่อลงชื่อออกจากงาน';
          iconPath = 'assets/images/click_checkin.svg';
          isDisabled = false;
          fontSize = 32;
          break;
        case "WORKING":
          buttonColor = AppColors.buttonDisable;
          buttonText = "อยู่ในเวลางาน";
          iconPath = 'assets/images/intimejob.svg';
          showtext = 'กรุณากลับมาเช็คเอาค์ด้วยตอนเวลาเลิกงาน';
          isDisabled = true;
          fontSize = 26;
          break;
        default: // CHECK_IN_READY
          buttonColor = AppColors.buttonCheckIn;
          buttonText = "เช็คอิน";
          showtext = 'กรุณากดปุ่ม “เช็คอิน” เพื่อลงชื่อเข้างาน';
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
                  onTap: isDisabled ? null : () async {
                    try {
                      HapticFeedback.mediumImpact();

                      // 1. ดึงเวลามาตรฐานจาก NTP
                      DateTime ntpTime = await NTP.now(lookUpAddress: 'time.google.com');

                      // 2. แปลงเวลาสำหรับแสดงผลบน UI (HH:mm)
                      String nowTime = DateFormat('HH:mm').format(ntpTime);

                      setState(() {
                        if (state == "CHECK_OUT_READY") {
                          checkOutTimeRecorded = nowTime;
                          hasCheckedOut = true;
                        } else {
                          checkInTimeRecorded = nowTime;
                          _hasCheckedIn = true;
                        }
                      });

                      // 3. บันทึกสถานะลงเครื่อง (Local Storage) เพื่อให้ปิดแอปแล้วจำได้
                      // โดยเรียกใช้ฟังก์ชันที่คุณเขียนไว้ ซึ่งจะใช้ AttendanceModel ในการบันทึก
                      await _saveCurrentState();

                      String requestType = (state == "CHECK_OUT_READY") ? "CHECK_OUT" : "CHECK_IN";

                      // 4. ส่งข้อมูลไปที่ Server (แยกวันที่และเวลาใน Service เรียบร้อยแล้ว)
                      // สมมติใช้ userId จากระบบของคุณ (ตัวอย่าง: 'U001')
                      final attendanceService = GetIt.I<AttendanceService>();
                      await attendanceService.postAttendance(ntpTime, requestType );

                      debugPrint("บันทึกสำเร็จลงทั้ง Local และ Server: $nowTime");

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('บันทึกเวลา $nowTime น. เรียบร้อยแล้ว')),
                      );

                    } catch (e) {
                      debugPrint("เกิดข้อผิดพลาด: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ไม่สามารถบันทึกได้ กรุณาตรวจสอบอินเทอร์เน็ต'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  customBorder: CircleBorder(),
                  child: Container(
                    width: 190,
                    height: 190,
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
            showtext,
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
                'กรุณาเช็คอินเข้างานภายในเวลา ${configSetting?.checkInTime?.hour.toString().padLeft(2, '0') ?? '--'}:${configSetting?.checkInTime?.minute.toString().padLeft(2, '0') ?? '--'} หากเช็คอินเกินเวลาจะถือเป็นการเข้างานสาย ระบบจะทำการตัดรอบเวลา ${configSetting?.cutoffTime?.hour.toString().padLeft(2, '0') ?? '--'}:${configSetting?.cutoffTime?.minute.toString().padLeft(2, '0') ?? '--'} ของทุกวัน',
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
    String state = _getButtonState();
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
              // state == "ABSENT" ? "ขาดงาน" :
              _buildStatusItem(iconPath: 'assets/images/in.svg', title: 'เช็คอิน', time: (_hasCheckedIn ? checkInTimeRecorded : "---")),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
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
      ],
    );
  }
}
