import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/services/history/attendance_history_model.dart';
import 'package:attendance_system/services/history/attendance_history_service.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/popup/date_filter_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater_promax.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// หน้าประวัติการเข้างาน (Attendance History)
/// - มีตัวกรองช่วงวันที่ (DateFilterPopup)
/// - ดึงข้อมูลจาก API ผ่าน AttendanceHistoryService
/// - จัดกลุ่มรายการตาม "เดือน/ปี" แล้วแสดงเป็นหัวข้อ + list
/// - คำนวณสถานะ: ตรงเวลา / สาย / ไม่สมบูรณ์ จากเวลาเข้างาน-ออกงาน
class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<StatefulWidget> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  // -----------------------------
  // 1) ตัวกรองวันที่ (Filter)
  // -----------------------------
  // วันเริ่มต้น/วันสิ้นสุด ที่ผู้ใช้เลือกไว้ (ส่งเข้า API เป็น query)
  bool _defaultFilterSet = false;
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);//DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime? filterStart;
  DateTime? filterEnd;

  // -----------------------------
  // 2) ข้อมูลหลักของหน้าจอ
  // -----------------------------
  // Mock Data
  final List<AttendanceHistoryModel> _mockItem = [
    AttendanceHistoryModel(
      // เข้างานปกติ
      date: DateTime.parse("2026-12-24"),
      dow: "พุธ",
      checkIn: "08:30",
      checkOut: "18:30",
      leavePeriod: "NONE",
    ),
    //** ลาเช้า **
    AttendanceHistoryModel(
      date: DateTime.parse("2026-12-25"),
      dow: "พฤหัสบดี",
      checkIn: "13:00",
      checkOut: "18:30",
      leavePeriod: "MORNING",
    ),
    AttendanceHistoryModel(
      date: DateTime.parse("2026-12-26"),
      dow: "ศุกร์",
      checkIn: "09:00",
      checkOut: "13:00",
      leavePeriod: "AFTERNOON",
    ),
    AttendanceHistoryModel(
      date: DateTime.parse("2026-12-27"),
      dow: "เสาร์",
      checkIn: null,
      checkOut: null,
      leavePeriod: "FULL_DAY",
    ),
  ];


  // รายการประวัติที่ดึงมาจาก API (แปลงเป็น Model แล้วเก็บไว้แสดงผล)
  List<AttendanceHistoryModel> _items = [];

  // -----------------------------
  // 3) เวลาเข้างานมาตรฐาน (เอาไว้เทียบว่าสายไหม)
  // -----------------------------
  // ค่า default เป็น 0 ไว้ก่อน แล้วจะไปอ่านจาก AuthState.timeConfig ตอน build
  int _stdInHour = 0;
  int _stdInMinute = 0;

  //เอาไว้ใช้กรณีที่ ลาเช้า จะใช้เวลานี้แทน
  int _checkInLeaveHour = 0;
  int _checkInLeaveMin = 0;

  @override
  Widget build(BuildContext context) {

    // --------------------------------------------
    // อ่าน config เวลาเข้างานจาก AuthState (Provider)
    // - AuthState.timeConfig ถูก preload ตอน login/init
    // - ใช้เป็น "เวลาเข้างานมาตรฐาน" เพื่อคำนวณ lateMinutes
    // --------------------------------------------
    ConfigAttendanceTimeModel? setting = context.watch<AuthState>().timeConfig;

    //เวลาเข้าทำงานมาตรฐาน
    _stdInHour = setting?.checkInTime.hour ?? 0;
    _stdInMinute = setting?.checkInTime.minute ?? 0;

    //จะใช้ตอนลาเช้า แล้วมา checkIn ตอนบ่าย (ค่า default เป็น 13.00 ถ้าไม่ได้เปลี่ยน)
    var _checkInLeave = setting?.checkInLeaveTime;
    debugPrint("_checkInLeave: $_checkInLeave");
    _checkInLeaveHour = setting?.checkInLeaveTime.hour?? 0;
    debugPrint("_checkInLeaveHour: $_checkInLeaveHour");
    _checkInLeaveMin = setting?.checkInLeaveTime.minute?? 0;
    debugPrint("_checkInLeaveMin: $_checkInLeaveMin");

    return AppScaffold(
      header: Header.subHeader(context, title: "บันทึกการเข้างาน"),
      content: SafeArea(
        child: Container(
          // สีพื้นหลังของหน้า
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // ให้เลื่อนแล้วคีย์บอร์ดหายเอง
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    // ให้ scroll ได้แม้ข้อมูลน้อย (ใช้กับ pull/UX)
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      spacing: 13,
                      children: [

                        // ============================================================
                        // ServiceUpdaterProMax = ตัวช่วยเรียก request แบบมี state + trigger ได้
                        // - requests: คืน list ของ Future ที่ต้องยิง
                        // - onSuccess: ได้ data กลับมาแล้วค่อย setState
                        // - fetchOnInit: true แปลว่าเปิดหน้ามายิงเลย
                        // - builder: ให้ UI ได้ trigger(index) เพื่อยิงใหม่ได้
                        // ============================================================
                        ServiceUpdaterProMax(
                            requests: [
                              // ยิง API ดึงประวัติ โดยส่ง startDate/endDate
                              // _toYmd() แปลง DateTime -> "YYYY-MM-DD"
                              () => AttendanceHistoryService().fetchHistory(
                                //ถ้า ว่าง null ถ้าไม่  return เช่น "2026-03-02"
                                startDate: filterStart == null ? null : _toYmd(filterStart!),//เช่น "2026-03-02"
                                endDate: filterEnd == null ? null : _toYmd(filterEnd!),
                              )
                            ],

                            // ถูกเรียกเมื่อ request สำเร็จ (index=0 คือ request ตัวแรก)
                            // data คือ response ที่ service ส่งกลับมา (เป็น List)
                            onSuccess: (index, data) {
                              // แปลง response (data) เป็น list ของ AttendanceHistoryModel (from database)
                              _items = AttendanceHistoryModel.getList(data);

                              //ใช้ mock data
                              //_items = _mockItem;

                              //debug
                              debugPrint("=== onSuccess index: $index ===");
                              debugPrint("data runtimeType: ${data.runtimeType}");
                              debugPrint("data: $data");

                              // ตั้งค่า default filter ครั้งแรกจากข้อมูลใน DB
                              if(!_defaultFilterSet && _items.isNotEmpty) {
                                //วันที่ของตัวแรกใน list เป็นค่าเริ่มต้นทั้ง max min
                                DateTime minDate = _items.first.date;
                                DateTime maxDate = _items.first.date;

                                //วนดูทุกวันใน list
                                // ถ้าเจอวัน “เก่ากว่า” → อัปเดต minDate
                                // ถ้าเจอวัน “ใหม่กว่า” → อัปเดต maxDate
                                for (final item in _items) {
                                  final d = item.date;
                                  if (d.isBefore(minDate)) minDate = d;
                                  if (d.isAfter(maxDate)) maxDate = d;
                                }

                                filterStart = _dateOnly(minDate); // startDate = วันที่มีข้อมูลเก่าสุด
                                filterEnd = _dateOnly(maxDate); // endDate = วันที่มีข้อมูลล่าสุด
                                _defaultFilterSet = true;
                              }
                              // เรียงจาก "ใหม่ -> เก่า"
                              _items.sort((a, b) => b.date.compareTo(a.date));
                              //เปลี่ยนค่ามาแล้ว “ข้างนอก” (ก่อนหน้า) เลยเรียก setState เพื่อ rebuild อย่างเดียว
                              setState(() {});//rebuild
                              },

                            // เปิดหน้าแล้วให้ยิง request ทันที
                            fetchOnInit: true,//ถ้าเป็น false ต้อง “สั่งโหลด” ก่อนถึงจะมีรายการขึ้น

                            // builder ให้สร้าง UI โดยมี:
                            // - trigger(i): ยิง request ลำดับ i ใหม่
                            // - getState(i): ดู state ของ request i (loading/success/error)
                            builder: (trigger, getState) {
                              // --------------------------------------------------
                              // จัดกลุ่มข้อมูลตามเดือน/ปี เพื่อทำหัวข้อ
                              // groupedItems: key = "มกราคม 2569", value = list ของวันในเดือนนั้น
                              // --------------------------------------------------
                              final Map<String, List<AttendanceHistoryModel>> groupedItems = {};

                              //Loop ดึงข้อมูล
                              for (final item in _items){
                                final d = _dateOnly(item.date);//เอาข้อมูลแค่วันมาใช้

                                //ถ้า วันที่ d มาก่อน วันของ filterStart -> ข้าม
                                if(filterStart != null && d.isBefore(_dateOnly(filterStart!))){
                                  continue;
                                }

                                //ถ้า วันที่ d มาหลัง วันของ filterEnd -> ข้าม
                                if(filterEnd != null && d.isAfter(_dateOnly(filterEnd!))){
                                  continue;
                                }

                                final label = _monthYearLabel(d);//ex = "มีนาคม 2569"
                                //groupedItems คือ Map key เป็น String (เช่น "มีนาคม 2569") value เป็น List<AttendanceHistoryModel> (รายการของเดือนนั้น)
                                //putIfAbsent = ถ้าใน Map ยังไม่มี key นี้ ให้สร้างค่าเริ่มต้นให้มัน Ex. ถ้า groupedItems ยังไม่มี "มีนาคม 2569" → ให้ใส่ key นี้เข้าไป พร้อม value เป็น [] (list ว่าง)
                                // .add(item) เพื่อ เพิ่ม item เข้า list ของเดือนนั้น
                                groupedItems.putIfAbsent(label, ()=> []).add(item);
                                //ก็คือแบบว่า เอา item เข้าเดือนนั้น ถ้าเป็นเดือนใหม่ที่ยังไม่เคยมีใน groupedItems มันจะสร้าง key ใหม่ให้ใน groupedItems
                              }

                              return Column(
                                spacing: 13,
                                children: [

                                  // ================= UI ส่วนที่ 1: กล่องตัวกรอง (Filter) =================
                                  InkWell(
                                    // กดแล้วเปิด DateFilterPopup
                                    onTap: () {
                                      DateFilterPopup(
                                        // ส่งค่าปัจจุบันเข้าไป เพื่อให้ popup แสดงค่าที่เคยเลือกไว้
                                          currentDateFrom: filterStart,
                                          currentDateTo: filterEnd,

                                          // callback ตอนกด "บันทึก" ใน popup
                                          onSubmit: (start, end) {
                                            setState(() {
                                              // เก็บค่าวันที่ที่เลือกไว้ใน state ของหน้า
                                              filterStart = start;
                                              filterEnd = end;
                                            });

                                            // ยิง request ใหม่ (index 0) เพื่อโหลดข้อมูลตาม filter
                                            trigger(0);
                                          }
                                      ).showPopup(context);
                                    },
                                    //UI
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        color: const Color(0xFFE9E9E9),//เทาอ่อน
                                      ),
                                      child: Column(
                                        spacing: 6,
                                        children: [
                                          Row(
                                            spacing: 6,
                                            children: [
                                              SizedBox(
                                                width: 15,
                                                height: 15,
                                                child: SvgPicture.asset(
                                                  'assets/images/filterIcon__attendance.svg',
                                                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                ),
                                              ),
                                              const Text('ตัวกรอง'),
                                              // ถ้ากำลังโหลด request 0 อยู่ แสดง spinner เล็กๆ
                                              if (getState(0) == ServiceUpdaterProMaxState.loading)
                                                const CupertinoActivityIndicator(radius: 7),
                                            ],
                                          ),

                                          // กล่องแสดงวันที่จาก/ถึงที่เลือกไว้
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Row(
                                              spacing: 10,
                                              children: [
                                                // ฝั่งซ้าย "จากวันที่"
                                                Expanded(
                                                    child: Row(
                                                      spacing: 10,
                                                      children: [
                                                        SvgPicture.asset('assets/images/calendar_in.svg'),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              'จากวันที่',
                                                              style: TextStyle(color: Color(0xFF626262)),
                                                            ),
                                                            Text(
                                                              // แปลงเป็น dd/mm/yyyy+543 หรือ "---"
                                                              _formatDateDisplay(filterStart),
                                                              style: const TextStyle(fontSize: 14),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                ),

                                                // เส้นแบ่งกลาง
                                                Container(width: 1.5, height: 40, color: const Color(0xFFB1B1B1)),

                                                // ฝั่งขวา "ถึงวันที่"
                                                Expanded(
                                                    child: Row(
                                                      spacing: 10,
                                                      children: [
                                                        SvgPicture.asset('assets/images/calendar_out.svg'),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              'ถึงวันที่',
                                                              style: TextStyle(color: Color(0xFF626262)),
                                                            ),
                                                            Text(
                                                              _formatDateDisplay(filterEnd),
                                                              style: const TextStyle(fontSize: 14),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),

                                  // ================= UI ส่วนที่ 2: รายการประวัติ (History List) =================
                                  // ถ้าไม่มีข้อมูล และไม่ได้กำลังโหลดอยู่ -> แสดง "ไม่มีข้อมูล"
                                  if (_items.isEmpty && getState(0) != ServiceUpdaterProMaxState.loading)
                                    SeparatorCard(
                                      children: [
                                        Container(
                                          color: Colors.white,
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(25),
                                          child: const Text(
                                            'ไม่มีข้อมูล',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF7D7D7D),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  else
                                    // ถ้ามีข้อมูล -> วนตามเดือน/ปี
                                    Column(
                                      spacing: 15,
                                      //สร้าง children หลายตัว โดย วนตามแต่ละกลุ่ม (แต่ละเดือน/ปี) แล้วเอา widget ที่สร้างได้ทั้งหมดมาเป็น list ใส่ใน children
                                      children: groupedItems.entries.map((entry) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 8,
                                          children: [
                                            // หัวข้อเดือน/ปี เช่น "ธันวาคม 2569"
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Text(
                                                entry.key,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ),

                                            // กล่องรายการของเดือนนั้นๆ
                                            SeparatorCard(
                                              separatorPadding: const EdgeInsets.only(left: 95, right: 15),
                                              children: entry.value.map((item) {

                                                // -----------------------------
                                                // เตรียมข้อมูลแถว (row) ก่อนแสดง
                                                // -----------------------------
                                                final day = item.date.day.toString(); // เลขวัน เช่น "18"
                                                final dow = item.dow ?? _thaiDowFromDate(item.date); // วันในสัปดาห์
                                                final timeIn = item.checkIn ?? "--:--"; // เวลาเข้างาน
                                                final timeOut = item.checkOut ?? "--:--"; // เวลาออกงาน
                                                final leavePeriod = item.leavePeriod ?? "NONE";

                                                // คำนวณสี/ข้อความสถานะ/ชั่วโมงทำงาน
                                                final ui = _computeUi(
                                                    dow: dow,
                                                    timeIn: timeIn,
                                                    timeOut: timeOut,
                                                    leavePeriod: leavePeriod,
                                                );

                                                // -----------------------------
                                                // UI ของแต่ละแถว
                                                // -----------------------------
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      // Badge วันที่: เลขวัน + วันในสัปดาห์
                                                      Container(
                                                        width: 64,
                                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: ui["bgColor"],
                                                          borderRadius: BorderRadius.circular(14),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Text(day, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2)),
                                                            Text(dow, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 20),

                                                      // รายละเอียดเวลา + สถานะ
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            // แถวเวลาเข้างาน/ออกงาน
                                                            Row(
                                                              children: [
                                                                Text("เข้างาน  ", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                                                Text(timeIn, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                                                const SizedBox(width: 11),
                                                                Text("|", style: TextStyle(color: Colors.grey.shade400)),
                                                                const SizedBox(width: 11),
                                                                Text("ออกงาน  ", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                                                Text(timeOut, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 8),

                                                            // แถวสถานะ + ชั่วโมงทำงาน
                                                            Row(
                                                              children: [
                                                                // Chip สถานะ: ตรงเวลา/สาย/ไม่สมบูรณ์ พร้อมไอคอน
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                                  decoration: BoxDecoration(
                                                                    color: ui["statusBg"],
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      SvgPicture.asset(
                                                                        ui["statusIconAsset"],
                                                                        width: 16,
                                                                        height: 16,
                                                                        // ย้อมสีไอคอนให้เป็นสีเดียวกับข้อความสถานะ
                                                                        colorFilter: ColorFilter.mode(ui["statusFg"], BlendMode.srcIn),
                                                                      ),
                                                                      const SizedBox(width: 6),
                                                                      Text(
                                                                        ui["statusText"],
                                                                        style: TextStyle(
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: ui["statusFg"],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 12),

                                                                // ไอคอนนาฬิกา + duration ชั่วโมงทำงาน
                                                                SvgPicture.asset(
                                                                  'assets/images/clock_attendance.svg',
                                                                  width: 16,
                                                                  height: 16,
                                                                ),
                                                                const SizedBox(width: 6),
                                                                Text(ui["duration"], style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            )
                                          ],
                                        );
                                      }).toList(),
                                    )
                                ],
                              );
                            }
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= Helpers (แยกเฉพาะ Logic เท่านั้น) =================

  /// แปลง DateTime -> "YYYY-MM-DD" (ใช้ส่งเป็น query ให้ backend)
  String _toYmd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  /// แสดงวันที่แบบไทย: dd/mm/(yyyy+543) ถ้า null แสดง "---"
  String _formatDateDisplay(DateTime? date) {
    if (date == null) return "---";
    return "${date.day}/${date.month}/${date.year + 543}";
  }

  /// แปลงเลขเดือน -> ชื่อเดือนภาษาไทย
  String _thaiMonth(int m) {
    const months = ['', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'];
    if (m < 1 || m > 12) return '';
    return months[m];
  }

  /// แสดงหัวข้อเดือน/ปีแบบไทย เช่น "ธันวาคม 2569"
  String _monthYearLabel(DateTime d) => "${_thaiMonth(d.month)} ${d.year + 543}";

  /// ถ้า backend ส่ง dow เป็น null -> คำนวณจาก DateTime.weekday
  String _thaiDowFromDate(DateTime d) {
    switch (d.weekday) {
      case 1: return 'จันทร์';
      case 2: return 'อังคาร';
      case 3: return 'พุธ';
      case 4: return 'พฤหัสบดี';
      case 5: return 'ศุกร์';
      case 6: return 'เสาร์';
      case 7: return 'อาทิตย์';
      default: return '';
    }
  }

  /// เช็คว่าเวลาหาย/ไม่สมบูรณ์ไหม (ใช้เพื่อแยกเคส "ไม่สมบูรณ์")
  bool _isMissingTime(String t) {
    final s = t.trim();
    return s.isEmpty || s == '--:--' || s == '--.--' || s == '-';
  }

  /// แปลง String เวลา "08.30" หรือ "08:30" -> DateTime(2000-01-01 HH:MM)
  /// ใช้วันที่คงที่ (2000-01-01) เพื่อให้เปรียบเทียบเวลาได้ง่าย
  DateTime _parseTime(String t) {
    final s = t.trim().replaceAll('.', ':');
    final parts = s.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(2000, 1, 1, h, m);
  }
  //ที่เลือก 2000-01-01 เพื่อทำให้ “เวลา” กลายเป็น DateTime ที่เทียบกันง่าย โดยไม่เอาวันจริงมาเกี่ยวครับ

  /// แปลง Duration -> "H:MM" เช่น 7:05, 13:00
  String _formatHourMinute(Duration d) {
    if (d.isNegative) return '--:--';
    final totalMin = d.inMinutes;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  /// แปลงจำนวน "นาที" -> "H:MM" เช่น 75 -> 1:15
  String _formatMinutesToHourMinute(int minutes) {
    if (minutes <= 0) return '0:00';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  /// เลือกสีพื้น badge ตามวันในสัปดาห์ (เพื่อทำ UI ให้ต่างกัน)
  Color _badgeColorByDow(String dow) {
    switch (dow.trim()) {
      case 'จันทร์': return const Color(0xFFFFF3CD);
      case 'อังคาร': return const Color(0xFFF7ECFE);
      case 'พุธ': return const Color(0xFFEAF5EE);
      case 'พฤหัสบดี': return const Color(0xFFFFE0B2);
      case 'ศุกร์': return const Color(0xFFBBDEFB);
      case 'เสาร์': return const Color(0xFFE1BEE7);
      case 'อาทิตย์': return const Color(0xFFFFE5E5);
      default: return const Color(0xFFF2F4F7);
    }
  }

  /// คำนวณข้อมูล UI สำหรับแถวประวัติ 1 แถว:
  /// - สี badge ตามวัน
  /// - สถานะ: ไม่สมบูรณ์ / สาย / ตรงเวลา
  /// - duration ชั่วโมงทำงาน
  /// - ไอคอน/สีสำหรับ status chip
  Map<String, dynamic> _computeUi({
    required String dow,
    required String timeIn,
    required String timeOut,
    required String leavePeriod
  }) {
    final badgeColor = _badgeColorByDow(dow);
    final inMissing = _isMissingTime(timeIn);
    final outMissing = _isMissingTime(timeOut);

    // เคส 1) เวลาเข้า/ออกหายอย่างน้อยหนึ่งฝั่ง -> ไม่สมบูรณ์
    if (inMissing || outMissing) {
      return {
        "bgColor": badgeColor,
        "statusText": "ไม่สมบูรณ์",
        "statusBg": const Color(0xFFFFE5E5),
        "statusFg": const Color(0xFFD32F2F),
        "duration": "--.-- ชั่วโมง",
        "statusIconAsset": "assets/images/warning2_outline__attendance.svg",
      };
    }

    // แปลงเวลาเข้า/ออก เป็น DateTime เพื่อหาผลต่าง
    final DateTime inDt = _parseTime(timeIn);
    final DateTime outDt = _parseTime(timeOut);


    // ถ้าลาเช้า (MORNING) ใช้เวลา checkInLeaveTime เป็นมาตรฐานแทน
    final DateTime stdDt = (leavePeriod == "MORNING")
        ? DateTime(2000, 1, 1, _checkInLeaveHour, _checkInLeaveMin)// ถ้าใช่ setting?.checkIn
        : DateTime(2000, 1, 1, _stdInHour, _stdInMinute);// ถ้าไม่ เวลาเข้างานมาตรฐาน จาก setting?.checkInTime

    // lateMinutes > 0 แปลว่าเข้างานช้ากว่าเวลามาตรฐาน
    final lateMinutes = inDt.difference(stdDt).inMinutes;

    // duration = เวลาออก - เวลาเข้า
    final duration = _formatHourMinute(outDt.difference(inDt));

    // เคส 2) สาย
    if (lateMinutes > 0) {
      late String lateText;

      // ถ้าสายเกิน 60 นาที -> แสดงเป็นชั่วโมง:นาที
      if (lateMinutes >= 60) {
        lateText = "สาย ${_formatMinutesToHourMinute(lateMinutes)} ชม.";
      } else {
        // ถ้าสายน้อยกว่า 60 นาที -> แสดงเป็นนาที
        lateText = "สาย $lateMinutes นาที";
      }

      return {
        "bgColor": badgeColor,
        "statusText": lateText,
        "statusBg": const Color(0xFFFFF3CD),
        "statusFg": const Color(0xFFB26A00),
        "duration": "$duration ชั่วโมง",
        "statusIconAsset": "assets/images/warning_outline__attendance.svg",
      };
    }

    // เคส 3) ตรงเวลา (ไม่สาย และข้อมูลครบ)
    return {
      "bgColor": badgeColor,
      "statusText": "ตรงเวลา",
      "statusBg": const Color(0xFFE6F4EA),
      "statusFg": const Color(0xFF1E8E3E),
      "duration": "$duration ชั่วโมง",
      "statusIconAsset": "assets/images/check_circle__attendance.svg",
    };
  }
}