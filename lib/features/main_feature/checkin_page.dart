import 'dart:async';

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
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../services/check-in/check-in_model.dart';
import '../../services/check-in/check-in_service.dart';
import '../../services/check-in/check_in-leave-model.dart';
import '../../services/check-in/check_in-leave-service.dart';
import '../../services/check-in/holiday_service.dart';
import '../../shared/widgets/utils/clock_realtime.dart';
import '../../shared/widgets/utils/radar_animation.dart';
import '../../shared/widgets/utils/separator_card.dart';

class CheckinPage extends StatefulWidget {
  const CheckinPage({super.key});

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> with WidgetsBindingObserver {
  DateTime? _currentNetworkTime;
  AttendanceLeaveModel? currentLeave;

  bool _isLoadingState = true; // เริ่มต้นให้เป็น true เสมอ

  String checkInTimeRecorded = "---";
  String checkOutTimeRecorded = "---";
  String holiday = "";

  bool _hasCheckedIn = false;
  bool isDisabled = false;
  bool hasCheckedOut = false;

  // bool isOnLeave = false; // ลางาน
  bool isPublicHoliday = false; // วันหยุดราชการ/นักขัตฤกษ์

  ConfigAttendanceTimeModel? configSetting;

  Timer? _timer;
  DateTime? _lastResetDate;
  Duration? _timeOffset = Duration.zero;
  // 🚩 แก้ (2026-08-13): กันไม่ให้นาฬิกาโชว์เวลา local ก่อนแล้วค่อยกระโดดไปเวลา server
  // (เห็นเป็นจังหวะ "กระตุก" ตอนเข้าหน้า) — ไม่โชว์เวลาจนกว่าจะ sync เสร็จ (สำเร็จหรือ fail ก็ได้)
  bool _timeSynced = false;

  // Bug 1.3: Inline feedback state
  String _feedbackMessage = '';
  bool _feedbackIsSuccess = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPage();
  }

  /// Bug 1.1: Initialize with local time immediately (used internally for data loading,
  /// ไม่ได้ใช้โชว์ในนาฬิกา — ดู _timeSynced), แล้วอัปเกรดเป็น server time
  Future<void> _initPage() async {
    _currentNetworkTime = DateTime.now();
    _timeOffset = Duration.zero;

    // 🚩 ยิง sync ตั้งแต่ต้นแบบขนาน (ไม่ await) จะได้ทำงานพร้อมกับ config/data load ด้านล่าง
    // แทนที่จะรอโหลดอย่างอื่นเสร็จก่อนค่อยเริ่ม sync — ลดเวลาที่นาฬิกาค้างสถานะ "กำลังซิงค์"
    _tryFetchServerTime();

    // Load config
    await initConfig();

    // Load attendance state and supplementary data
    await _loadSupplementaryData(_currentNetworkTime!);
    await _loadInitialState(_currentNetworkTime!);

    // Start the clock
    _startTimerLogic();
  }

  /// Bug 1.1: Attempt to fetch server time; if successful, update offset
  /// 🚩 แก้ (2026-08-13): เดิมพึ่ง timeapi.io (third-party) ซึ่งพบว่าเวลาเพี้ยนไปเกือบ 30 นาที
  /// จากเวลาจริง (verify แล้วผ่าน NTP) เปลี่ยนมาใช้ backend เราเอง (GET /api/server-time) แทน
  /// เพราะควบคุม/เชื่อถือได้กว่า — backend คืนเวลาเครื่อง server เป็น UTC (มี 'Z' ชัดเจน
  /// DateTime.parse ถึง parse เป็น UTC ตรงๆ ได้เลย ไม่ต้อง reinterpret เอง)
  Future<void> _tryFetchServerTime() async {
    try {
      final response = await GetIt.I<ApiClient>()
          .dio
          .get('/api/server-time')
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && mounted) {
        final DateTime serverTimeUtc = DateTime.parse(response.data['utc']).toUtc();
        setState(() {
          _timeOffset = serverTimeUtc.difference(DateTime.now().toUtc());
          _currentNetworkTime = DateTime.now().add(_timeOffset!);
          _timeSynced = true;
        });
        debugPrint("✅ Server time synced, offset: $_timeOffset");
      }
    } catch (e) {
      debugPrint("ℹ️ Server time unavailable, using local clock: $e");
      // Silently continue with local time — not a problem, but still mark "synced" so the
      // clock doesn't hang on the loading state forever if the request fails/times out
      if (mounted) {
        setState(() {
          _timeSynced = true;
        });
      }
    }
  }

  /// Load supplementary data (holidays, leave) for the given time
  Future<void> _loadSupplementaryData(DateTime time) async {
    try {
      final holidayService = GetIt.I<HolidayService>();
      final leaveService = GetIt.I<Leaveservice>();

      String today = DateFormat('yyyy-MM-dd').format(time);

      final results = await Future.wait([
        holidayService.getPublicHolidays(today).catchError((e) {
          debugPrint("❌ Holiday Service Error: $e");
          return Response(requestOptions: RequestOptions(path: ''), statusCode: 500);
        }),
        leaveService.getLeave(today).catchError((e) {
          debugPrint("❌ Leave Service Error: $e");
          return Response(requestOptions: RequestOptions(path: ''), statusCode: 500);
        }),
      ]);

      final holidayRes = results[0];
      final leaveRes = results[1];

      if (!mounted) return;

      setState(() {
        if (holidayRes.statusCode == 200 && holidayRes.data != null) {
          var hData = holidayRes.data;
          if (hData['holiday_name'] != null &&
              hData['holiday_name'].toString().isNotEmpty) {
            isPublicHoliday = true;
            holiday = hData['holiday_name'];
          }
        }

        if (leaveRes.statusCode == 200 && leaveRes.data != null) {
          debugPrint("Leave Data จาก Backend: ${leaveRes.data}");
          Map<String, dynamic> responseData = leaveRes.data;
          String today = DateFormat('yyyy-MM-dd').format(time);

          if (responseData['data'] != null && responseData['data'][today] != null) {
            var todayLeaveData = responseData['data'][today];
            currentLeave = AttendanceLeaveModel.fromJson(todayLeaveData);
            debugPrint("✅ แกะข้อมูลลาสำเร็จ: ประเภท ${currentLeave?.leaveType}, อนุมัติ: ${currentLeave?.isApproved}");
          } else {
            debugPrint("ℹ️ วันนี้ไม่มีประวัติการลา");
          }
        }
      });
    } catch (e) {
      debugPrint("ไม่สามารถดึงได้ :$e}");
    }
  }

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
    setState(() {
      _isLoadingState = true; // เริ่มแสดงหน้าโหลด
    });

    try {
      final attendanceService = GetIt.I<AttendanceService>();
      final todayStr = DateFormat('yyyy-MM-dd').format(networkTime);

      // ดึงข้อมูลจาก Server
      final serverData = await attendanceService.getTodayAttendance(todayStr);

      if (serverData != null) {
        setState(() {
          checkInTimeRecorded = serverData.checkInTime ?? "---";
          checkOutTimeRecorded = serverData.checkOutTime ?? "---";
          _hasCheckedIn = serverData.hasCheckedIn;
          hasCheckedOut = serverData.hasCheckedOut;
        });
        await attendanceService.saveLocalState(serverData);
      } else {
        // ถ้า Server ไม่มี ให้เช็ค Local
        final localData = await attendanceService.getLocalState(networkTime);
        if (localData != null) {
          setState(() {
            checkInTimeRecorded = localData.checkInTime ?? "---";
            checkOutTimeRecorded = localData.checkOutTime ?? "---";
            _hasCheckedIn = localData.hasCheckedIn;
            hasCheckedOut = localData.hasCheckedOut;
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingState = false; // ปิดหน้าโหลดเมื่อข้อมูลทุกอย่างพร้อม
        });
      }
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



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel(); // ล้าง Timer เพื่อประหยัด Memory
    super.dispose();
  }

  // 💡 ฟังก์ชันนี้จะถูกเรียกอัตโนมัติเมื่อผู้ใช้พับแอปแล้วเปิดขึ้นมาใหม่
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("ผู้ใช้กลับมาหน้าแอป (Resumed) -> โหลดข้อมูลจาก Server ใหม่");

      // ถ้ามีเวลาเครือข่ายอยู่แล้ว ให้สั่งโหลด _loadInitialState ใหม่ทันที
      if (_currentNetworkTime != null) {
        _loadInitialState(_currentNetworkTime!);
      }
    }
  }

  void _checkAndResetLogic(ConfigAttendanceTimeModel? configSetting) {
    if (_currentNetworkTime == null || configSetting == null) return;

    final now = _currentNetworkTime!;

    final isCutoffTime =
        now.hour == configSetting.cutoffTime.hour &&
        now.minute == configSetting.cutoffTime.minute;

    final notToday =
        _lastResetDate == null ||
        _lastResetDate!.year != now.year ||
        _lastResetDate!.month != now.month ||
        _lastResetDate!.day != now.day;

    if (isCutoffTime && notToday) {
      debugPrint("🔥 ถึง cutoffTime → RESET");

      _resetDailyData(now);
      _lastResetDate = now;
    }
    // debugPrint("NOW: $now");
    // debugPrint("CUTOFF: ${configSetting.cutoffTime}");
  }

  Future<void> _resetDailyData(DateTime now) async {
    setState(() {
      checkInTimeRecorded = "---";
      checkOutTimeRecorded = "---";
      _hasCheckedIn = false;
      hasCheckedOut = false;
      _lastResetDate = now;
    });
    await _saveCurrentState();
    debugPrint("ระบบทำการ Reset ข้อมูลประจำวันเรียบร้อยแล้ว");
  }

  // String _getButtonState() {
  //   if (_currentNetworkTime == null) return "CHECK_IN_READY";
  //
  //   final now = _currentNetworkTime!;
  //   final hour = now.hour;
  //   final minute = now.minute;
  //   final double currentTime = now.hour + (now.minute / 60);
  //
  //   final double checkInLeaveLimit = configSetting!.checkInLeaveTime.hour + (configSetting!.checkInLeaveTime.minute / 60);
  //   final double checkOutLeaveLimit = configSetting!.checkOutLeaveTime.hour + (configSetting!.checkOutLeaveTime.minute / 60);
  //   final double regularCheckOutTime = configSetting!.checkOutTime.hour + (configSetting!.checkOutTime.minute / 60);
  //   if (isPublicHoliday) return "PUBLIC_HOLIDAY";
  //
  //   if (currentLeave != null && currentLeave!.isApproved) {
  //
  //     // กรณี: ลาเต็มวัน
  //     if (currentLeave!.leaveType == "FULL_DAY") {
  //       return "LEAVE_FULL_DAY";
  //     }
  //
  //     // กรณี: ลาครึ่งวันเช้า (ต้องเข้างานตามเวลา checkInLeaveTime)
  //     else if (currentLeave!.leaveType == "MORNING") {
  //       if (currentTime < checkInLeaveLimit) {
  //         return "LEAVE_MORNING"; // ยังอยู่ในช่วงลา
  //       }
  //       // ถ้าเลยเวลา checkInLeaveLimit แล้ว แต่ยังไม่เช็คอิน -> โชว์ปุ่มเช็คอิน
  //     }
  //
  //     // กรณี: ลาครึ่งวันบ่าย (ต้องอยู่งานถึงเวลา checkOutLeaveLimit)
  //     else if (currentLeave!.leaveType == "AFTERNOON") {
  //       if (currentTime >= checkOutLeaveLimit) {
  //         return "LEAVE_AFTERNOON"; // เข้าสู่ช่วงลาบ่ายแล้ว
  //       }
  //       // ถ้ายังไม่ถึงเวลาลาบ่าย -> ให้ทำงานตาม Logic ปกติ (เช็คอิน/เอาต์)
  //     }
  //   }
  //
  //   bool isAfterWork =
  //       hour > configSetting!.checkOutTime.hour ||
  //       (hour == configSetting!.checkOutTime.hour &&
  //           minute >= configSetting!.checkOutTime.minute);
  //
  //   if (hasCheckedOut) return "FINISHED";
  //
  //   if (isAfterWork) {
  //     if (_hasCheckedIn) {
  //       return "CHECK_OUT_READY";
  //     } else {
  //       return "ABSENT";
  //     }
  //   }
  //   if (!_hasCheckedIn) return "CHECK_IN_READY";
  //
  //   return "WORKING";
  // }

  String _getButtonState() {
    if (_currentNetworkTime == null || configSetting == null) return "CHECK_IN_READY";

    final now = _currentNetworkTime!;
    final double currentTime = now.hour + (now.minute / 60);

    // ดึงค่าเวลาจาก Config
    final double checkInLeaveLimit = configSetting!.checkInLeaveTime.hour + (configSetting!.checkInLeaveTime.minute / 60);
    final double checkOutLeaveLimit = configSetting!.checkOutLeaveTime.hour + (configSetting!.checkOutLeaveTime.minute / 60);
    final double regularCheckOutTime = configSetting!.checkOutTime.hour + (configSetting!.checkOutTime.minute / 60);

    // 1. ตรวจสอบวันหยุดราชการ
    if (isPublicHoliday) return "PUBLIC_HOLIDAY";

    // 2. ตรวจสอบสถานะการลา
    if (currentLeave != null && currentLeave!.isApproved) {
      if (currentLeave!.leaveType == "FULL_DAY") return "FULL_DAY";

      // ลาครึ่งวันเช้า: ถ้ายังไม่ถึงเวลาเข้างานช่วงบ่าย ให้โชว์ปุ่มลา
      if (currentLeave!.leaveType == "MORNING" && currentTime < checkInLeaveLimit) {
        return "MORNING";
      }

      // ลาครึ่งวันบ่าย: ถ้าถึงเวลาเริ่มลาบ่ายแล้ว ให้โชว์ปุ่มลา (ยกเว้นเช็คเอาต์ไปแล้ว)
      if (currentLeave!.leaveType == "AFTERNOON" && currentTime >= checkOutLeaveLimit) {
        if (hasCheckedOut) return "FINISHED";
        return "AFTERNOON";
      }
    }

    // 3. ตรวจสอบวันหยุดสุดสัปดาห์ (เรียกฟังก์ชันเดิมของคุณ)
    if (_checkIsWeekend()) return "WEEKEND";

    // 4. ตรวจสอบว่าเช็คเอาต์ไปหรือยัง
    if (hasCheckedOut) return "FINISHED";

    // 5. คำนวณเวลาเลิกงานที่เหมาะสม (Effective Checkout Time)
    // ถ้าลาบ่าย ให้ใช้ checkOutLeaveLimit เป็นเกณฑ์เลิกงาน เพื่อให้ปุ่มเช็คเอาต์ปรากฏ
    double effectiveCheckOutTime = (currentLeave?.leaveType == "AFTERNOON" && currentLeave!.isApproved)
        ? checkOutLeaveLimit
        : regularCheckOutTime;

    bool isAfterWork = currentTime >= effectiveCheckOutTime;

    if (isAfterWork) {
      return _hasCheckedIn ? "CHECK_OUT_READY" : "ABSENT";
    }

    // 6. สถานะการเข้างานปกติ
    return _hasCheckedIn ? "WORKING" : "CHECK_IN_READY";
  }

  bool _checkIsWeekend() {
    if (_currentNetworkTime == null) return false;
    int day = _currentNetworkTime!.weekday;
    return day == DateTime.saturday || day == DateTime.sunday;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideNavigation: false,
      header: Header.mainHeader(
        context,
        title: 'ลงเวลาปฏิบัติงาน',
        subTitle: 'Time Attendance',
        iconPath: 'checkin_title_logo.svg',
      ),
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    // Show loading while config or initial state is loading
    if (_isLoadingState || configSetting == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CupertinoActivityIndicator(radius: 15)],
        ),
      );
    }

    // Bug 1.2: Use tighter padding and spacing for mobile layout
    // 🚩 (2026-08-22) ไม่มี scroll แล้ว — ทุก component ต้องพอดีหน้าเดียว
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _cardtime(),
            // 🚩 (2026-08-24) Flexible + FittedBox ข้างใน (ดู _buttonCheckin)
            // ทำให้บล็อกปุ่ม "ยอมหด" เมื่อที่ไม่พอ แทนที่จะดันจนล้น
            //
            // เจอตอนกดเช็คอินสำเร็จ: ข้อความ "บันทึกเวลา ... เรียบร้อยแล้ว"
            // โผล่เพิ่มมา 1 บรรทัด -> overflow 4px (console: RenderFlex overflowed
            // by 4.0 pixels, constraints h<=593)
            //
            // แก้แบบเบียดพอดี 4px ไม่ปลอดภัย เพราะยังมีเคสอื่นที่ข้อความยาวกว่านี้
            // (error message ยาวๆ / ชื่อวันหยุดยาว) แล้วตกบรรทัดเพิ่มอีก
            Flexible(child: _buttonCheckin()),
            const SizedBox(height: 6),
            _currentstate(),
          ],
        ),
      ),
    );
  }

  void _startTimerLogic() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _timeOffset != null) {
        setState(() {
          // 💡 เวลาแสดงผล = เวลาเครื่องจริง + ส่วนต่าง (ทำให้เน็ตหลุดนาฬิกาก็ยังเดินตรงเป๊ะ)
          _currentNetworkTime = DateTime.now().add(_timeOffset!);
          _checkAndResetLogic(configSetting);
        });
      }
    });
  }

  Widget _cardtime() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 15,
              width: 15,
              child: SvgPicture.asset('assets/images/clock.svg'),
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
          child: Column(children: [ClockWidget(time: _timeSynced ? _currentNetworkTime : null)]),
        ),
      ],
    );
  }

  Widget _buttonCheckin() {
    String state = _getButtonState(); // ดึงสถานะปัจจุบันตามเวลาจริง
    bool isWeekend = _checkIsWeekend();

    Color buttonColor;
    String buttonText;
    String showtext;
    String iconPath;
    double fontSize;
    bool isDisabled = false;

    if (isPublicHoliday) {
      buttonColor = AppColors.buttonDisable;
      buttonText = "วันหยุดราชการ";
      showtext = 'วันนี้คือ $holiday';
      iconPath = 'assets/images/publicholiday.svg';
      isDisabled = true;
      fontSize = 24;
    } else if (isWeekend) {
      buttonColor = AppColors.buttonDisable;
      buttonText = "วันหยุด";
      showtext = 'วันหยุดสุดสัปดาห์';
      iconPath = 'assets/images/weekend.svg';
      isDisabled = true;
      fontSize = 32;
    } else {
      switch (state) {
        case "FULL_DAY":
          buttonColor = AppColors.buttonDisable;
          buttonText = currentLeave?.leaveName ?? "ลาเต็มวัน";
          showtext = 'วันนี้คุณได้ลางานทั้งวัน';
          iconPath = 'assets/images/leave.svg';
          isDisabled = true;
          fontSize = 27;
          break;

        case "MORNING":
          buttonColor = AppColors.buttonDisable;
          buttonText = "ลาช่วงเช้า";
          // ดึงเวลาเข้างานจาก Config มาแสดง
          String checkInTime = "${configSetting!.checkInLeaveTime.hour.toString().padLeft(2, '0')}:${configSetting!.checkInLeaveTime.minute.toString().padLeft(2, '0')}";
          showtext = 'คุณลางานช่วงลาเช้า กรุณาเช็คอินหลัง $checkInTime น.';
          iconPath = 'assets/images/leave.svg';
          isDisabled = true;
          fontSize = 27;
          break;

        case "AFTERNOON":
          buttonColor = AppColors.buttonDisable;
          buttonText = "ลาช่วงบ่าย";
          showtext = 'คุณลางานช่วงบ่าย';
          iconPath = 'assets/images/leave.svg';
          isDisabled = true;
          fontSize = 27;
          break;

        case "ABSENT":
          buttonColor = AppColors.buttonDisable;
          buttonText = "ขาดงาน";
          showtext = 'ขาดงาน';
          iconPath = 'assets/images/absent.svg';
          isDisabled = true;
          fontSize = 27;
          break;

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

    return SingleChildScrollView(
      child: Column(
        children: [
          // Bug 1.2: Reduced sizes for mobile layout
          // 🚩 (2026-08-24) ที่ไม่พอเมื่อไหร่ ให้ปุ่มหดลงตามสัดส่วน (เรดาร์/ไอคอน/
          // ตัวหนังสือ/เงา หดตามกันหมด) แทนที่จะล้นออกนอกจอ
          // ถ้าที่พอ FittedBox จะไม่ทำอะไรเลย -> หน้าตาเหมือนเดิมเป๊ะ
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Stack(
            alignment: Alignment.center,
            children: [
              RadarAnimation(color: buttonColor),
              Padding(
                // 🚩 (2026-08-22) เดิม 240 -> ดันความสูง Stack เป็น 252 ทั้งที่ปุ่มมีแค่ 170
                // (เงาลอยห่างใต้ปุ่ม 29px) กินที่เกินจำเป็นจนหน้าไม่พอดีต้องเลื่อน
                // สูตร: ระยะห่างเงาจากขอบล่างปุ่ม = (ค่านี้ - 182) / 2
                // 202 -> เงาห่างปุ่ม 10px, Stack สูง 214 (ประหยัดไป 38px)
                // ขนาดปุ่ม/เรดาร์/ระยะห่างระหว่าง component อื่นๆ เท่าเดิมทุกอย่าง
                padding: EdgeInsets.only(top: 220),
                child: Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightTextColor.withValues(alpha: 0.2),
                        blurRadius: 1,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.elliptical(150, 15)),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (isDisabled || _isSubmitting)
                      ? null
                      : () => _handleCheckin(state),
                  customBorder: CircleBorder(),
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: buttonColor,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 36,
                          width: 36,
                          child: SvgPicture.asset(iconPath),
                        ),
                        SizedBox(height: 1),
                        _isSubmitting
                            ? const CupertinoActivityIndicator(color: Colors.white)
                            : Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            showtext,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w200,
              color: AppColors.greyTextColor,
            ),
          ),

          // Bug 1.3: Inline feedback text
          if (_feedbackMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _feedbackMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _feedbackIsSuccess ? Colors.green : Colors.red,
              ),
            ),
          ],

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 15,
                width: 15,
                child: SvgPicture.asset('assets/images/iicon.svg'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  softWrap: true,
                  textAlign: TextAlign.start,
                  'กรุณาเช็คอินเข้างานภายในเวลา ${configSetting?.checkInTime?.hour.toString().padLeft(2, '0') ?? '--'}:${configSetting?.checkInTime?.minute.toString().padLeft(2, '0') ?? '--'}'
                      ' หากเช็คอินเกินเวลาจะถือเป็นการเข้างานสาย ระบบจะทำการตัดรอบเวลา ${configSetting?.cutoffTime?.hour.toString().padLeft(2, '0') ?? '--'}:${configSetting?.cutoffTime?.minute.toString().padLeft(2, '0') ?? '--'} ของทุกวัน',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: AppColors.lightTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bug 1.3 & 1.4: Handle check-in/check-out — only update UI on backend success
  Future<void> _handleCheckin(String state) async {
    try {
      HapticFeedback.mediumImpact();

      setState(() {
        _isSubmitting = true;
        _feedbackMessage = '';
      });

      final DateTime exactTime = DateTime.now().add(
        _timeOffset ?? Duration.zero,
      );
      String nowTimeDisplay = DateFormat('HH:mm').format(exactTime);

      String requestType = (state == "CHECK_OUT_READY")
          ? "CHECK_OUT"
          : "CHECK_IN";
      final attendanceService = GetIt.I<AttendanceService>();

      // Bug 1.4: Send to backend FIRST, only update UI on success
      await attendanceService.postAttendance(exactTime, requestType);

      // Backend succeeded — now update UI state
      setState(() {
        if (state == "CHECK_OUT_READY") {
          checkOutTimeRecorded = nowTimeDisplay;
          hasCheckedOut = true;
        } else {
          checkInTimeRecorded = nowTimeDisplay;
          _hasCheckedIn = true;
        }
        _feedbackMessage = 'บันทึกเวลา $nowTimeDisplay น. เรียบร้อยแล้ว';
        _feedbackIsSuccess = true;
      });

      await _saveCurrentState();
    } on DioException catch (e) {
      // Bug 1.4: Parse actual backend error message
      String errorMsg = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          errorMsg = data['error'] ?? data['message'] ?? errorMsg;
        } else if (data is String && data.isNotEmpty) {
          errorMsg = data;
        }
      }
      debugPrint("เกิดข้อผิดพลาดในการบันทึก: $e");
      setState(() {
        _feedbackMessage = errorMsg;
        _feedbackIsSuccess = false;
      });
    } catch (e) {
      debugPrint("เกิดข้อผิดพลาดในการบันทึก: $e");
      setState(() {
        _feedbackMessage = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
        _feedbackIsSuccess = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _currentstate() {
    String state = _getButtonState();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                child: SvgPicture.asset('assets/images/i_icon.svg'),
              ),
              const SizedBox(width: 5),
              Text(
                'สถานะปัจจุบัน',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SeparatorCard(
            separatorPadding: EdgeInsetsGeometry.only(left: 52, right: 10),
            children: [
              // state == "ABSENT" ? "ขาดงาน" :
              _buildStatusItem(
                iconPath: 'assets/images/in.svg',
                title: 'เช็คอิน',
                time: (_hasCheckedIn ? checkInTimeRecorded : "---"),
              ),
              _buildStatusItem(
                iconPath: 'assets/images/out.svg',
                title: 'เช็คเอาท์',
                time: hasCheckedOut ? checkOutTimeRecorded : '---',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String iconPath,
    required String title,
    required String time,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 15,
            right: 20,
          ),
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
