import 'dart:async';

import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_model.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_service.dart';
import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/services/history/attendance_history_model.dart';
import 'package:attendance_system/services/history/attendance_history_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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

  /// ประวัติ 5 วันล่าสุด — ใช้เฉพาะ layout จอกว้าง
  ///
  /// `null` = ยังไม่รู้ผล (กำลังโหลด) · `[]` = ไม่มีข้อมูลหรือดึงไม่สำเร็จ -> ซ่อนไปเลย
  /// **ห้ามให้ก้อนนี้บล็อกการเช็คอินเด็ดขาด** — ยิงแยกไม่ await และพังเงียบๆ ได้
  List<AttendanceHistoryModel>? _recentHistory;
  bool _recentRequested = false;

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

  /// ดึงประวัติล่าสุดสำหรับแผงฝั่งขวาของ layout จอกว้าง
  ///
  /// ยิงตอนเข้าโหมด expanded ครั้งแรกเท่านั้น — มือถือไม่ต้องเสีย request ทิ้ง
  /// เพราะไม่มีที่จะโชว์อยู่แล้ว
  Future<void> _loadRecentHistory() async {
    try {
      // ขอเกิน 5 มา 1 เผื่อแถวของ "วันนี้" ที่จะถูกตัดออก (สถานะวันนี้มีอยู่
      // ในแผงด้านบนแล้ว โชว์ซ้ำในประวัติจะกลายเป็นข้อมูลเดียวกันสองที่)
      final res = await AttendanceHistoryService().fetchHistory(limit: 6);
      if (!mounted) return;

      final body = res.data;
      // ส่ง limit ไป backend ตอบ {data, total, has-more} · ไม่ส่งจะตอบ array ดิบ
      final rawList = body is Map ? (body['data'] as List? ?? const []) : (body as List? ?? const []);

      final now = DateTime.now();
      bool isToday(DateTime d) =>
          d.year == now.year && d.month == now.month && d.day == now.day;

      setState(() {
        _recentHistory = AttendanceHistoryModel.getList(rawList)
            .where((m) => !isToday(m.date))
            .take(5)
            .toList();
      });
    } catch (e) {
      debugPrint('ℹ️ ดึงประวัติล่าสุดไม่ได้ (ไม่กระทบการเช็คอิน): $e');
      if (mounted) setState(() => _recentHistory = const []);
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
      // 🚩 (Phase 3) จอที่วางคอลัมน์เดียว (มือถือ / iPad แนวตั้ง) กว้าง 1100 เกิน
      // จำเป็นมาก — 560 คือความกว้างที่วงกลมเช็คอินยังเป็นพระเอกอยู่
      // ส่วนโหมด expanded วางสองคอลัมน์จึงต้องการที่กว้างกว่านั้น
      // expanded — ไม่จำกัด เพราะเนื้อหามีเพดานของตัวเองอยู่แล้ว (_wideMaxWidth)
      // medium (iPad แนวตั้ง) — 560 ที่เคาะมาจากมือถือทำให้เหลือขอบว่างข้างละ
      //   ~130 บนจอ 834
      //
      //   🚩 (2026-08-25) ขยับ 700 -> 860 เพราะ iPad Pro 13 แนวตั้งกว้าง 1032
      //   ที่ 700 เหลือขอบข้างละ ~165 ดูโล่งเหมือนลืมจัด ที่ 860 เหลือข้างละ
      //   ~85 อ่านเป็นขอบที่ตั้งใจ
      //
      //   ไม่ปล่อยเต็มจอ เพราะ layout แนวตั้งเรียงกล่องซ้อนกัน พอยืดเต็ม 1032
      //   ป้ายจะชิดซ้ายสุดและค่าชิดขวาสุดห่างกันเกือบ 1000 ซึ่งเป็นอาการเดิม
      //   ที่ Phase 3 ไล่แก้มาทั้งงาน (PHASE3_PAGE_DESIGN.md ข้อ 1)
      // compact — 560 ไม่มีผลอยู่แล้วเพราะมือถือแคบกว่านั้น เก็บไว้กันจอใหญ่สุด
      maxWidth: switch (Responsive.mode(context)) {
        LayoutMode.expanded => double.infinity,
        LayoutMode.medium => 860,
        LayoutMode.compact => 560,
      },
      header: Header.mainHeader(
        context,
        title: 'ลงเวลาปฏิบัติงาน',
        subTitle: 'Time Attendance',
        iconPath: 'checkin_title_logo.svg',
      ),
      content: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Show loading while config or initial state is loading
    if (_isLoadingState || configSetting == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CupertinoActivityIndicator(radius: 15)],
        ),
      );
    }

    // ยิงโหลดประวัติครั้งเดียวพอ ไม่ว่าจะ layout ไหน
    if (!_recentRequested) {
      _recentRequested = true;
      // ยิงหลังเฟรมนี้ กัน setState ระหว่าง build
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecentHistory());
    }

    // โหมด expanded (iPad แนวนอน / desktop) มีที่ทางแนวนอนเหลือเฟือแต่ความสูง
    // จำกัด — ย่อ layout ของมือถือมาใส่จึงได้คอลัมน์ผอมๆ กลางจอที่เหลือที่ว่าง
    // สองข้างเปล่าๆ ตรงนี้จึงแยกเป็น layout ของตัวเองไปเลย
    if (Responsive.mode(context) == LayoutMode.expanded) return _wideContent();

    // 🚩 (2026-08-24, รอบสอง) เดิมจอแคบ "ห้ามเลื่อน" — ทุกก้อนต้องพอดีหน้าเดียว
    // ซึ่งบังคับให้ใช้ spaceBetween + Flexible คุมความสูงบล็อกปุ่มแบบเบียดๆ
    //
    // พอเพิ่มประวัติล่าสุดเข้ามา (ให้มีเหมือนจอใหญ่) กติกานั้นใช้ไม่ได้อีกแล้ว
    // เลยเปลี่ยนเป็นเรียงลงมาตรงๆ แล้วเลื่อนเอา ซึ่งได้ของแถมคือไม่ต้องกลัว
    // overflow ตอนข้อความยาวขึ้น (เคสที่เคยทำให้ overflow 4px)
    // 🚩 (2026-08-25) `AppScaffold` วางเนื้อหาไว้ใน `Align(topCenter)` ซึ่งส่ง
    // constraints แบบ **loose** ลงมา (min 0) — `SingleChildScrollView` เจอแบบนี้
    // จะ "หดตามความสูงเนื้อหา" แทนที่จะกินพื้นที่ที่เหลือทั้งหมด
    //
    // ผลคือ viewport สูงเท่าเนื้อหา (ราว 940) ไม่ใช่เท่าพื้นที่จริง (ราว 1150)
    // บน iPad แนวตั้ง พอผู้ใช้ลากเลื่อน เนื้อหาจึงถูกตัดที่ขอบ viewport ที่ลอย
    // อยู่กลางจอ แล้วเหลือช่องว่างใต้ลงไปจนถึงแถบเมนู (ยืนยันด้วยการใส่สีพื้น
    // ให้ scroll view ชั่วคราวแล้วถ่ายภาพ — สีจบก่อนถึงแถบเมนูจริงๆ)
    //
    // แก้ด้วยการบังคับให้เนื้อหาสูงอย่างน้อยเท่าพื้นที่ที่ได้รับ -> viewport
    // เต็มพื้นที่เสมอ ส่วนตอนเนื้อหายาวกว่านั้นก็เลื่อนได้ตามปกติ
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _cardtime(),
            const SizedBox(height: 20),
            // ตัวหน้ามี scroll ให้แล้ว บล็อกปุ่มจึงไม่ต้องมีของตัวเองซ้อนอีก
            _buttonCheckin(scrollable: false),
            const SizedBox(height: 20),
            _currentstate(),
            const SizedBox(height: 13),
            _sideBox(child: _recentBox()),
          ],
        ),
        ),
        ),
      ),
      ),
    );
  }

  /// layout เฉพาะของ iPad แนวนอน / desktop — ไม่ใช่ layout มือถือที่ย่อมา
  ///
  /// ผืนผ้าเต็มพื้นที่ แบ่งเป็นสองฝั่ง:
  ///   ซ้าย 2 ส่วน = กล่องเช็คอิน  วงกลม + กติกาเวลา
  ///   ขวา  1 ส่วน = เวลา / สถานะ / ประวัติ เรียงลงมา
  ///
  /// 🚩 เพดาน 1280×920 แล้วจัดกลาง — ไม่ใช่การ "จำกัดความกว้าง" แบบเดิมที่ทำให้
  /// iPad อึดอัด (iPad Pro 13 แนวนอนได้พื้นที่ราว 1095×890 จึงไม่โดนเพดานเลย
  /// หน้าตายังเต็มเหมือนเดิมทุกประการ) แต่กันเคส desktop จอ 1920+ ที่เนื้อหา
  /// ยืดจนกล่องกติกากลายเป็นแถบยาวเส้นเดียว คอลัมน์ขวากว้างเกิน 500
  /// และกล่องประวัติสูงจนเหลือที่ว่างใต้ 5 แถวเป็นครึ่งกล่อง
  static const double _wideMaxWidth = 1280;
  static const double _wideMaxHeight = 920;

  Widget _wideContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _wideMaxWidth,
              maxHeight: _wideMaxHeight,
            ),
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Expanded(flex: 2, child: _checkInBox()),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ไม่ห่อพื้นเทา — ใช้หน้าตาเดียวกับมือถือ (ป้ายจัดกลาง
                  // ด้านบน แล้วการ์ดขาวข้างใต้)
                  _cardtime(large: true),
                  const SizedBox(height: 16),
                  _sideBox(child: _currentstate(bare: true)),
                  const SizedBox(height: 16),
                  // ประวัติกินที่ที่เหลือทั้งหมด -> ขอบล่างของคอลัมน์ขวาชนขอบล่าง
                  // ของกล่องเช็คอินพอดี ทั้งบล็อกจึงเป็นสี่เหลี่ยมเต็ม ไม่แหว่ง
                  // ความสูงมาจาก layout ไม่ใช่จำนวนแถวที่ดึงมาได้ จึงยังนิ่งเหมือนเดิม
                  Expanded(child: _sideBox(child: _recentBox(fill: true))),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// กล่องเช็คอิน — ไม่มีพื้นหลัง วงกลมกับกติกาเวลาเป็นก้อนเดียวกันจัดกึ่งกลาง
  ///
  /// ไม่ปักกติกาไว้ขอบล่าง เพราะมันเป็นคำอธิบายของปุ่ม ควรอยู่ติดปุ่ม
  Widget _checkInBox() {
    // 🚩 "จัดกลางถ้าพอ เลื่อนถ้าไม่พอ"
    //
    // วงกลม 280 + เงา + ข้อความ + กล่องกติกา รวมแล้วราว 470 ถ้าความสูงที่ได้รับ
    // น้อยกว่านั้นจะล้น (RenderFlex overflowed) — เกิดได้จริงตอนผู้ใช้ซูมหน้าเว็บ
    // หรือย่อหน้าต่างเบราว์เซอร์ให้เตี้ย ไม่ใช่เคสหายาก
    //
    // ConstrainedBox(minHeight) ทำให้เนื้อหาสูงอย่างน้อยเท่าช่องที่ได้ -> Center
    // ข้างในจึงจัดกลางได้ตามปกติเมื่อที่พอ ส่วนตอนที่ไม่พอ เนื้อหาสูงกว่าช่อง
    // แล้ว SingleChildScrollView ก็เลื่อนแทนการล้น
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: _buttonCheckin(
                circleSize: 280,
                large: true,
                scrollable: false,
              ),
            ),
          ),
        );
      },
    );
  }

  /// กล่องมาตรฐานของคอลัมน์ขวา — เทาห่อขาว เป็นภาษาเดียวกับหน้า /statistic
  ///
  /// แยกเป็นกล่องละเรื่องแทนที่จะรวมเป็นแผงเดียว: นาฬิกา / สถานะวันนี้ /
  /// ประวัติล่าสุด เป็นคนละเรื่องกัน ขอบกล่องช่วยบอกว่าอ่านจบเรื่องนึงแล้ว
  Widget _sideBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }

  /// ความสูงที่จองไว้ให้การ์ดประวัติ — 5 แถว × 40
  ///
  /// 🚩 จองตายตัวไว้เลย ไม่ปล่อยให้สูงตามจำนวนแถวจริง เพราะจำนวนแถวมาทีหลัง
  /// (โหลดแยก) และเปลี่ยนไปตามข้อมูลของแต่ละคน ถ้าปล่อยให้ยืดหด กล่องด้านบน
  /// จะกระโดดตอนข้อมูลมาถึง และคนละบัญชีจะเห็น layout คนละแบบ
  static const double _recentRowHeight = 40;
  static const int _recentRowCount = 5;

  /// ประวัติ 5 วันล่าสุด
  ///
  /// ตอบคำถามที่คนถามจริงบนหน้านี้: "เมื่อวานลืมเช็คเอาท์รึเปล่า" โดยไม่ต้อง
  /// ออกจากหน้า ส่วนคนที่อยากดูละเอียดมีปุ่มไป /attendance-history ให้
  ///
  /// กล่องสูงคงที่เสมอ ไม่ว่าจะกำลังโหลด / ว่าง / มีกี่แถว
  /// [fill] — ให้การ์ดกินความสูงที่เหลือแทนความสูงคงที่ 5 แถว
  ///   (ใช้ใน layout จัตุรัส ซึ่งความสูงมาจาก layout ไม่ใช่จำนวนแถว จึงยังนิ่ง)
  Widget _recentBox({bool fill = false}) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: _recentBody(scrollable: fill),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              height: 15,
              width: 15,
              child: SvgPicture.asset('assets/images/icon_attendance_history.svg'),
            ),
            const SizedBox(width: 5),
            Text(
              'ล่าสุด',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
            ),
            const Spacer(),
            InkWell(
              onTap: () => context.pushNamed(RouteNames.attendanceHistory),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      'ดูทั้งหมด',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 9,
                      width: 9,
                      child: SvgPicture.asset('assets/images/icon_next.svg'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        if (fill)
          Expanded(child: card)
        else
          SizedBox(height: _recentRowHeight * _recentRowCount, child: card),
      ],
    );
  }

  /// [scrollable] — ให้แถวเลื่อนอยู่ในการ์ดแทนที่จะล้น
  ///
  /// 🚩 แถวสูงตายตัวแถวละ 40 × 5 = 200 ส่วนการ์ดในโหมด `fill` สูงเท่าที่ layout
  /// เหลือให้ ซึ่งอาจน้อยกว่า 200 ได้จริง — ไม่ใช่แค่ตอนซูมหน้าเว็บ แต่รวมถึง
  /// หน้าต่างเบราว์เซอร์เตี้ยๆ บนโน้ตบุ๊กด้วย (ความสูงเนื้อหาเหลือ ~500 ก็ถึงแล้ว)
  /// พอล้นจะได้แถบเหลือง-ดำในโหมด debug และเนื้อหาโดนตัดในโหมด release
  ///
  /// ปล่อยให้เลื่อนข้างในแทนการล้น — การ์ดเตี้ยก็เห็น 2-3 แถวแล้วเลื่อนดูที่เหลือ
  /// (โหมดความสูงคงที่ของมือถือไม่ต้องใช้ เพราะการ์ดสูงพอดี 5 แถวเป๊ะอยู่แล้ว
  /// และหน้ามี scroll ของตัวเองอยู่ ใส่ไปจะแย่ง gesture กัน)
  Widget _recentBody({bool scrollable = false}) {
    final items = _recentHistory;

    if (items == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (items.isEmpty) {
      return Center(
        child: Text(
          'ยังไม่มีประวัติ',
          style: TextStyle(fontSize: 14, color: AppColors.lightTextColor),
        ),
      );
    }

    final rows = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Divider(height: 0),
            ),
          _recentRow(items[i]),
        ],
      ],
    );

    return scrollable
        ? SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: rows,
          )
        : rows;
  }

  Widget _recentRow(AttendanceHistoryModel m) {
    final onLeave = (m.leavePeriod ?? 'NONE') != 'NONE';
    final checkIn = m.checkIn?.trim();
    final checkOut = m.checkOut?.trim();

    return SizedBox(
      height: _recentRowHeight,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_shortDow(m)} ${m.date.day} ${_shortThaiMonth(m.date.month)}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (onLeave)
            Text(
              'ลางาน',
              style: TextStyle(fontSize: 14, color: AppColors.greyTextColor),
            )
          else ...[
            Text(
              (checkIn == null || checkIn.isEmpty) ? '--:--' : checkIn,
              style: const TextStyle(fontSize: 14),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '–',
                style: TextStyle(fontSize: 14, color: AppColors.lightTextColor),
              ),
            ),
            Text(
              (checkOut == null || checkOut.isEmpty) ? '--:--' : checkOut,
              // ลืมเช็คเอาท์เป็นเคสที่คนเปิดหน้านี้มาหา — ทำให้เห็นชัดกว่าเวลาปกติ
              //
              // 🚩 ห้ามใช้ AppColors.titleColor ตรงนี้ — ชื่อมันชวนเข้าใจผิดว่าเป็น
              // "สีตัวหนังสือหัวข้อ" แต่ค่าจริงคือ 0xFFFFFFFF (ขาว) ซึ่งมีไว้ใช้บน
              // พื้นสีเข้ม (เช่นตัวหนังสือในวงกลมเช็คอิน) เอามาใช้บนการ์ดขาวแล้ว
              // เวลาเช็คเอาท์หายไปเลย — `color: null` = ใช้สีปกติเท่าช่องเช็คอิน
              style: TextStyle(
                fontSize: 14,
                color: (checkOut == null || checkOut.isEmpty) ? Colors.red : null,
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  /// backend ส่ง `dow` เป็นชื่อเต็มภาษาไทย — ในแถวแคบๆ ใช้ตัวย่อพอ
  String _shortDow(AttendanceHistoryModel m) {
    const short = {
      'จันทร์': 'จ',
      'อังคาร': 'อ',
      'พุธ': 'พ',
      'พฤหัสบดี': 'พฤ',
      'ศุกร์': 'ศ',
      'เสาร์': 'ส',
      'อาทิตย์': 'อา',
    };
    final full = m.dow?.trim();
    if (full != null && short.containsKey(full)) return short[full]!;
    return const ['', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'][m.date.weekday];
  }

  String _shortThaiMonth(int month) => const [
        '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
        'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
      ][month];

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

  /// [large] — จอกว้างมีที่เหลือ ใช้ตัวเลขเวลาใหญ่ขึ้นและการ์ดสูงขึ้น
  /// ไม่งั้นการ์ดจะดูเป็นแถบบางๆ ลอยอยู่ในพื้นที่ว่างใหญ่ๆ
  Widget _cardtime({bool large = false}) {
    return Column(
      children: [
        Row(
          // จัดกลางทุกจอ — กล่องเวลาบนจอกว้างใช้หน้าตาเดียวกับมือถือ
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
          padding: EdgeInsets.symmetric(
            vertical: large ? 28 : 10,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(children: [
            ClockWidget(
              time: _timeSynced ? _currentNetworkTime : null,
              timeFontSize: large ? 60 : 40,
              dateFontSize: large ? 18 : 15,
            )
          ]),
        ),
      ],
    );
  }

  /// [circleSize] — เส้นผ่านศูนย์กลางวงกลมเช็คอิน
  ///
  /// 🚩 ทุกตัวเลขรอบวงกลมผูกกับค่านี้หมด อย่า hardcode เพิ่ม:
  ///   เรดาร์      = วง + 10   (ให้ฟุ้งออกมานอกปุ่มนิดหน่อย)
  ///   เงา         กว้าง 70% ของวง, ห่างจากขอบล่างปุ่ม = วง × 0.112
  ///   padding เงา = 12 + วง + ระยะห่าง × 2  ← ได้มาจากการแก้สมการ
  ///                 (ความสูง Stack = padding + 12 ซึ่งดันขอบล่างปุ่มลงมาครึ่งนึง)
  ///   ไอคอน/ตัวอักษรในปุ่ม คูณตามสัดส่วน วง/170
  ///
  /// เช็คค่าเดิม: วง 170 -> padding = 12 + 170 + 19×2 = 220 ✓ ตรงกับที่จูนไว้เดิม
  /// [scrollable] — ห่อด้วย SingleChildScrollView ให้เองมั้ย
  ///   ใส่ false เมื่อหน้าที่เรียกมี scroll ของตัวเองอยู่แล้ว (ไม่งั้นซ้อนกัน)
  /// [showNote] — รวมกล่องกติกาเวลา (ⓘ) มาด้วยมั้ย
  ///   ใส่ false เมื่ออยากวางกล่องนั้นเองคนละที่ (ดู `_checkInBox`)
  Widget _buttonCheckin({
    double circleSize = 170,
    bool large = false,
    bool scrollable = true,
    bool showNote = true,
  }) {
    final scale = circleSize / 170;
    final shadowGap = circleSize * 0.112;
    final shadowTop = 12 + circleSize + shadowGap * 2;
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

    final body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bug 1.2: Reduced sizes for mobile layout
          // ⚠️ ห้ามใส่ Flexible/Expanded ตรงนี้ — Column นี้อาจอยู่ใน
          // SingleChildScrollView ซึ่งให้ความสูงแบบ "ไม่จำกัด" ลูกที่เป็น flex
          // เลยคำนวณสัดส่วนไม่ได้ -> "RenderBox was not laid out" ยิงรัวทุกเฟรม
          Stack(
            alignment: Alignment.center,
            children: [
              RadarAnimation(color: buttonColor, size: circleSize + 10),
              Padding(
                // 🚩 (2026-08-22) เดิม 240 -> ดันความสูง Stack เป็น 252 ทั้งที่ปุ่มมีแค่ 170
                // (เงาลอยห่างใต้ปุ่ม 29px) กินที่เกินจำเป็นจนหน้าไม่พอดีต้องเลื่อน
                // สูตร: ระยะห่างเงาจากขอบล่างปุ่ม = (ค่านี้ - 182) / 2
                // 202 -> เงาห่างปุ่ม 10px, Stack สูง 214 (ประหยัดไป 38px)
                // ขนาดปุ่ม/เรดาร์/ระยะห่างระหว่าง component อื่นๆ เท่าเดิมทุกอย่าง
                padding: EdgeInsets.only(top: shadowTop),
                child: Container(
                  width: circleSize * 0.7,
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
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: buttonColor,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 36 * scale,
                          width: 36 * scale,
                          child: SvgPicture.asset(iconPath),
                        ),
                        SizedBox(height: 1),
                        _isSubmitting
                            ? const CupertinoActivityIndicator(color: Colors.white)
                            : Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: fontSize * scale,
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

          SizedBox(height: large ? 18 : 8),
          Text(
            showtext,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: large ? 17 : 13,
              fontWeight: large ? FontWeight.w400 : FontWeight.w200,
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

          if (showNote) ...[
            SizedBox(height: large ? 24 : 6),
            _infoNote(large: large),
          ],
        ],
      );

      return scrollable
          ? SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              child: body,
            )
          : body;
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// ข้อความกติกาเวลา — ประกอบจาก config ระบบทั้งหมด ไม่ใช่ค่าคงที่
  ///
  /// 🚩 (2026-08-24) เดิมพูดถึงแค่ 2 ค่าจาก 6 ค่าที่ตั้งได้ในหน้า
  /// `/settings/config-attendance` (เวลาเข้างาน กับ เวลาตัดรอบวัน) — "เวลาออกงาน"
  /// ไม่เคยถูกบอกเลยทั้งที่เป็นเวลาที่ผู้ใช้ต้องกลับมาเช็คเอาท์ ส่วนเวลาของ
  /// "ลาครึ่งวัน" ก็ถูกใช้ในตรรกะปุ่มอยู่แล้วแต่ไม่เคยบอกผู้ใช้
  ///
  /// ตอนนี้ประกอบจาก config ครบและเปลี่ยนตามสถานะการลาของวันนี้:
  ///   ลาครึ่งวันเช้า -> ใช้ "เวลาเข้างานเมื่อลาครึ่งวันเช้า" แทนเวลาเข้างานปกติ
  ///   ลาครึ่งวันเย็น -> ใช้ "เวลาออกงานเมื่อลาครึ่งวันเย็น" แทนเวลาออกงานปกติ
  ///                    และบอกด้วยถ้าเปิด "เช็คเอ้าท์อัตโนมัติ" ไว้
  String _infoText() {
    final config = configSetting;
    if (config == null) return '';

    final leaveType = currentLeave?.isApproved == true ? currentLeave?.leaveType : null;
    final isMorningLeave = leaveType == 'MORNING';
    final isAfternoonLeave = leaveType == 'AFTERNOON';

    final inAt = _fmtTime(isMorningLeave ? config.checkInLeaveTime : config.checkInTime);
    final outAt = _fmtTime(isAfternoonLeave ? config.checkOutLeaveTime : config.checkOutTime);
    final cutoff = _fmtTime(config.cutoffTime);

    final parts = <String>[];

    if (isMorningLeave) {
      parts.add('วันนี้คุณลาครึ่งวันเช้า กรุณาเช็คอินหลังเวลา $inAt');
    } else {
      parts.add('กรุณาเช็คอินเข้างานภายในเวลา $inAt'
          ' หากเช็คอินเกินเวลาจะถือเป็นการเข้างานสาย');
    }

    if (isAfternoonLeave) {
      parts.add('วันนี้คุณลาครึ่งวันเย็น เวลาออกงานคือ $outAt');
      if (config.autoCheckout) {
        parts.add('ระบบจะเช็คเอาท์ให้อัตโนมัติเมื่อถึงเวลา $outAt');
      }
    } else {
      parts.add('เวลาออกงานคือ $outAt');
    }

    parts.add('ระบบจะทำการตัดรอบเวลา $cutoff ของทุกวัน');

    return parts.join(' ');
  }

  /// กล่องกติกาเวลาเช็คอิน (ⓘ)
  ///
  /// 🚩 บนจอกว้างข้อความนี้เคยเป็นบรรทัดจางๆ ลอยใต้ปุ่มดูเหมือนของหลุด
  /// ใส่การ์ดนุ่มๆ ให้มันเป็น "ก้อน" หนึ่งของหน้าแทน
  Widget _infoNote({required bool large}) {
    return Container(
            padding: large
                ? const EdgeInsets.symmetric(horizontal: 18, vertical: 14)
                : EdgeInsets.zero,
            decoration: large
                ? BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            child: Row(
            // จัดทั้งก้อน (ไอคอน + ข้อความ) ไว้กลางกล่อง — mainAxisSize.min ทำให้
            // Row กว้างเท่าเนื้อหาจริง ไม่ยืดเต็มกล่องแล้วดันข้อความไปชิดซ้าย
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: large ? 17 : 15,
                width: large ? 17 : 15,
                child: SvgPicture.asset('assets/images/iicon.svg'),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  softWrap: true,
                  // ตัวข้อความเรียงซ้าย->ขวาตามปกติ ที่จัดกลางคือ "ก้อน"
                  // ไอคอน+ข้อความ ให้อยู่กลางการ์ดขาว (ดู mainAxisSize.min ข้างบน)
                  textAlign: TextAlign.start,
                  _infoText(),
                  style: TextStyle(
                    fontSize: large ? 13 : 11,
                    height: large ? 1.5 : null,
                    fontWeight: FontWeight.normal,
                    color: AppColors.lightTextColor,
                  ),
                ),
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

  /// [bare] — ไม่ต้องมีกรอบเทาของตัวเอง (ใช้ตอนถูกวางในแผงเทาใหญ่แล้ว
  /// ไม่งั้นจะได้เทาซ้อนเทา — ดู `_todayPanel`)
  Widget _currentstate({bool bare = false}) {
    String state = _getButtonState();
    return Container(
      width: double.infinity,
      padding: bare ? EdgeInsets.zero : const EdgeInsets.all(16),
      decoration: bare
          ? null
          : BoxDecoration(
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
