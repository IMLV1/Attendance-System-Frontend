

import 'package:attendance_system/services/history/attendance_history_model.dart';
import 'package:attendance_system/services/history/attendance_history_service.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/utils/popup/date_filter_popup.dart';
import '../../shared/widgets/utils/popup/push_popup.dart';
import '../../shared/widgets/utils/calendar.dart';


class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<StatefulWidget> createState() => _AttendanceHistoryState();

}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  //เอาไว้จำที่เคยกดเลือกไว้
  DateTime? _selectedFrom;
  DateTime? _selectedTo;

  String startDate = "---";
  String endDate = "---";
  String startTime = "---";
  String endTime = "---";

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(context, title: "บันทึกการเข้างาน"),
      content: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
          child: Column(
            children: [
              //1
              Container(
                width: double.infinity,
                child: Column(
                  //spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //ทำให้ “กล่องตัวกรอง” กดได้ (ห่อ Container เดิมด้วย InkWell)
                    InkWell(
                      onTap: (){
                        DateFilterPopup(
                            currentDateFrom: _selectedFrom,
                            currentDateTo: _selectedTo,
                            onSubmit: (DateTime? dateFrom, DateTime? dateTo) async {
                              //set state ใหม่หลังกดปุ่ม
                              setState(() {
                                _selectedFrom = dateFrom;
                                _selectedTo = dateTo;

                                //UI Display
                                startDate = (dateFrom == null) ? "---" : "${dateFrom.day}/${dateFrom.month}/${dateFrom.year+543}";
                                endDate = (dateTo == null) ? "---" : "${dateTo.day}/${dateTo.month}/${dateTo.year+543}";

                                debugPrint("from=$dateFrom to=$dateTo");
                              });
                              // โหลดใหม่ตามช่วงวันที่ (ถ้าคุณแก้ service ให้รับพารามิเตอร์แล้ว)
                              await _loadHistory();
                            }
                        ).showPopup(context);
                      },// Go To
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xADE3E3E3),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            //Filter + Day Container
                            // (คอมเมนต์เดิมอยู่ แต่ "ตัว Container ซ้ำ" ถูกเอาออกเพื่อไม่ให้ซ้อนกัน)
                            Column(
                              mainAxisSize: MainAxisSize.min, //ให้กว้างเท่าที่จำเป็น
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Icon + name
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, // ให้ Row/Column กว้าง/สูงเท่าที่จำเป็น ไม่ยืดเต็มพื้นที่
                                    mainAxisAlignment: MainAxisAlignment.center, // จัดลูกๆ ให้อยู่กึ่งกลางตามแนวหลัก (Row=แนวนอน, Column=แนวตั้ง)
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                          'assets/images/filterIcon__attendance.svg',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      const Text(
                                        "ตัวกรอง",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600, // ทำให้ตัวอักษรกึ่งหนา (SemiBold) เพื่อเน้นข้อความ
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //end Icon Name
                                const SizedBox(height: 6),

                                //white box + divider
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildPickerCell(
                                          "จากวันที่",
                                          startDate,
                                          Icons.calendar_today_outlined,
                                          h: 12,
                                          v: 5,
                                        ),
                                      ),
                                      _buildVerticalLine(),
                                      Expanded(
                                        child: _buildPickerCell(
                                          "ถึงวันที่",
                                          endDate,
                                          Icons.calendar_today_outlined,
                                          h: 12,
                                          v: 5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              //2
              Expanded(
                child: _buildHistoryList(), //เอาไปวางใต้ฟังก์ชัน _buildVerticalLine
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPickerCell(String label, String value, IconData icon , {double h = 10, double v = 4}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: h , vertical: v ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLine() => Container(width: 2, height: 40, color: AppColors.lightTextColor);

  //Month in thai
  String _thaiMonth(int m){
    const months = [
      '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    if (m < 1 || m > 12) return '';
    return months[m];
  }

  //year + 543 = thai year
  String _monthYearLabel(DateTime d) => "${_thaiMonth(d.month)} ${d.year + 543}";

  //ไว้กันเผื่อ DataBase ส่ง dow = null มา
  String _thaiDowFromDate(DateTime d) {
    switch (d.weekday) { // 1=Mon ... 7=Sun
      case 1:
        return 'จันทร์';
      case 2:
        return 'อังคาร';
      case 3:
        return 'พุธ';
      case 4:
        return 'พฤหัสบดี';
      case 5:
        return 'ศุกร์';
      case 6:
        return 'เสาร์';
      case 7:
        return 'อาทิตย์';
      default:
        return '';
    }
  }

  //

  /*
  //ตัวอย่าง (ข้อมูลปลอม) เอาไว้โชว์ UI ก่อน
  //from database
  final List<Map<String, dynamic>> _mock = [
    // ===== กุมภาพันธ์ 2027 =====
    {"date": "2027-02-28", "dow": "อาทิตย์", "checkIn": "16:30", "checkOut": "16:30"},
    {"date": "2027-02-27", "dow": "เสาร์",   "checkIn": "14:45", "checkOut": "18:00"},
    {"date": "2027-02-26", "dow": "ศุกร์",    "checkIn": "08:45", "checkOut": "17:40"},
    {"date": "2027-02-25", "dow": "พฤหัสบดี","checkIn": "08:30", "checkOut": "18:20"},
    {"date": "2027-02-24", "dow": "พุธ",      "checkIn": "08:55", "checkOut": "17:30"},
    {"date": "2027-02-23", "dow": "อังคาร",   "checkIn": "08:30", "checkOut": null}, // ไม่สมบูรณ์
    {"date": "2027-02-22", "dow": "จันทร์",   "checkIn": "08:25", "checkOut": "17:30"},

    // ===== มกราคม 2027 =====
    {"date": "2027-01-31", "dow": "อาทิตย์", "checkIn": "08:30", "checkOut": "17:30"},
    {"date": "2027-01-30", "dow": "เสาร์",   "checkIn": "09:20", "checkOut": "18:10"},
    {"date": "2027-01-29", "dow": "ศุกร์",    "checkIn": "08:40", "checkOut": "17:35"},
    {"date": "2027-01-28", "dow": "พฤหัสบดี","checkIn": "08:30", "checkOut": "17:50"},
    {"date": "2027-01-27", "dow": "พุธ",      "checkIn": "08:30", "checkOut": "18:30"},
    {"date": "2027-01-26", "dow": "อังคาร",   "checkIn": "09:05", "checkOut": "17:30"}, // สาย
    {"date": "2027-01-25", "dow": "จันทร์",   "checkIn": "08:30", "checkOut": "17:30"},
    {"date": "2027-01-24", "dow": "อาทิตย์", "checkIn": "09:30", "checkOut": "18:30"},

    // ===== ธันวาคม 2026 (ข้ามปีจาก 2026 -> 2027) =====
    {"date": "2026-12-31", "dow": "พฤหัสบดี","checkIn": "08:50", "checkOut": "17:30"}, // สาย
    {"date": "2026-12-30", "dow": "พุธ",      "checkIn": "08:30", "checkOut": "17:40"},
    {"date": "2026-12-29", "dow": "อังคาร",   "checkIn": "08:35", "checkOut": "18:00"}, // สาย
    {"date": "2026-12-28", "dow": "จันทร์",   "checkIn": "08:30", "checkOut": "17:30"},
    {"date": "2026-12-27", "dow": "อาทิตย์", "checkIn": "09:00", "checkOut": null}, // ไม่สมบูรณ์
    {"date": "2026-12-26", "dow": "เสาร์",   "checkIn": "08:30", "checkOut": "12:30"},
    {"date": "2026-12-25", "dow": "ศุกร์",    "checkIn": "08:30", "checkOut": "17:30"},
    {"date": "2026-12-24", "dow": "พฤหัสบดี","checkIn": "09:30", "checkOut": "18:30"}, // สาย
    {"date": "2026-12-23", "dow": "พุธ",      "checkIn": "07:30", "checkOut": "22:30"},
    {"date": "2026-12-22", "dow": "อังคาร",   "checkIn": "08:30", "checkOut": null}, // ไม่สมบูรณ์
  ];
   */

  //**ดึง API
  //เพิ่ม state:
  final _historyService = AttendanceHistoryService();//สร้าง Object ดึง API
  List<AttendanceHistoryModel> _items = [];//set เป็นว่างไว้ก่อน เตรียมรอใส่
  bool _loading = true;
  String? _error;//เก็บข้อความ error ไว้แสดง ถ้า API มีปัญหา

  //เตรียมหน้าจอ
  @override
  void initState() {
    // TODO: implement deactivate
    super.initState();// ทำของ Flutter ก่อน (เตรียมหน้าจอ)
    _loadHistory();// แล้วเราเพิ่ม "ดึงข้อมูลจาก API" ต่อเลย
  }

  String _toYmd(DateTime d){
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }
  //เพิ่ม helper จัดการช่วงวันที่ + format ให้ถูก
  DateTime _dateTime(DateTime d) => DateTime(d.year,d.month,d.day);
  DateTime _endTime(DateTime d) => DateTime(d.year,d.month,d.day,23,59,59);

  

  //load
  Future<void> _loadHistory() async{
    try {
      //เริ่ม  → loading = true
      setState(() {
        _loading = true;
        _error = null;
      });

      //ดึง API → ได้ข้อมูล → เรียงวันที่ → แสดงผล
      final items = await _historyService.fetchHistory(
        startDate: _selectedFrom == null ? null : _toYmd(_selectedFrom!),
        endDate: _selectedTo == null ? null : _toYmd(_selectedTo!)
      );// รอดึงข้อมูลจาก API ก่อน แล้วเก็บไว้ใน items
      items.sort((a,b) => b.date.compareTo(a.date));
      // เรียงจากใหม่ไปเก่า
      // b.date.compareTo(a.date) = เอาวันที่ล่าสุดขึ้นก่อน

      setState(() {
        _items = items;// เอาข้อมูลที่ได้มาใส่ list แล้วหน้าจอจะอัพเดทอัตโนมัติ
      });
    }catch (e){
      //error  → เก็บข้อความ error
      setState(() {
        _error = e.toString();// เก็บข้อความ error ไว้แสดงบนหน้าจอ
      });
    }finally {//เมื่อจบ ทำเสมอไม่ว่าจะสำเร็จหรือ error
      setState(() {
        _loading = false;// ปิด loading spinner ทุกกรณี
      });
    }
  }

  static const int _stdInHour = 8;
  static const int _stdInMinute = 30;

  //ถ้า string นั้นว่าง return true
  bool _isMissingTime (String t){
    final s = t.trim();
    return s.isEmpty || s == '--:--' || s == '--.--' || s == '-';
  }

  /// รองรับ "08.30" หรือ "08:30"
  DateTime _parseTime(String t) {
    final s = t.trim().replaceAll('.', ':');
    final parts = s.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(2000, 1, 1, h, m);
  }
  // แปลง String เวลา ("08.30"/"08:30") เป็น DateTime โดย **fix วันที่เป็น 2000-01-01**
  // Parse เวลาเป็น DateTime (กำหนดวันที่คงที่ไว้เพื่อใช้เปรียบเทียบเวลา)
  // รองรับ . หรือ : และคืนค่าเป็น DateTime ของวันสมมติ 2000-01-01

  /// duration แบบ H:MM เช่น 7:48, 13:00
  /// ใช้เมื่อคุณมี “ผลต่างเวลา” อยู่แล้ว เช่น checkOut - checkIn
  String _formatHourMinute(Duration d) {
    if (d.isNegative) return '--:--';
    final totalMin = d.inMinutes;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  /// รับ Int -> แปลง "นาที" เป็นรูปแบบ H:MM (เช่น 60 -> 1:00, 75 -> 1:15)
  String _formatMinutesToHourMinute(int minutes) {
    if (minutes <= 0) return '0:00';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  //ประจำวันจ้า
  Color _badgeColorByDow(String dow) {
    switch (dow.trim()) {
      case 'จันทร์':
        return const Color(0xFFFFF3CD); // เหลืองอ่อน
      case 'อังคาร':
        return const Color(0xFFF7ECFE); // ชมพูอ่อน (ตาม mock เดิมคุณ)
      case 'พุธ':
        return const Color(0xFFEAF5EE); // เขียวอ่อน
      case 'พฤหัสบดี':
        return const Color(0xFFFFE0B2); // Orange
      case 'ศุกร์':
        return const Color(0xFFBBDEFB); // Blue
      case 'เสาร์':
        return const Color(0xFFE1BEE7);//ม่วงอ่อนพาสเทล
      case 'อาทิตย์':
        return const Color(0xFFFFE5E5); //แดงอ่อนพาสเทล
      default:
        return const Color(0xFFF2F4F7); //grey
    }
  }

  Map<String,dynamic> _computeUi({
    required String dow,
    required String timeIn,
    required String timeOut,
  }) {
    final badgeColor = _badgeColorByDow(dow);

    //boolean เดี๋ยวจะเอาไปใช้ต่อ ตอนเทียบเงือนไข
    final inMissing = _isMissingTime(timeIn);//inMissing = true ถ้า timeIn เป็นค่าว่าง หรือ --:--
    final outMissing = _isMissingTime(timeOut);// outMissing = true ถ้า timeOut เป็นค่าว่าง หรือ --:--

    // 1) ไม่สมบูรณ์ (ตามภาพ: out เป็น --:-- => ไม่สมบูรณ์)
    if (inMissing || outMissing) {
      return {
        "bgColor": badgeColor,
        "statusText": "ไม่สมบูรณ์",
        "statusBg": const Color(0xFFFFE5E5),//ชมพูอ่อนมาก
        "statusFg": const Color(0xFFD32F2F),//แดงเข้ม
        "duration": "--.-- ชั่วโมง",
        "statusIconAsset": "assets/images/warning2_outline__attendance.svg", // ไอคอน
      };
    }

    final inDt = _parseTime(timeIn);
    final outDt = _parseTime(timeOut);
    final stdDt = DateTime(2000, 1, 1, _stdInHour, _stdInMinute);

    final lateMinutes = inDt.difference(stdDt).inMinutes; // >0 คือสาย
    final duration = _formatHourMinute(outDt.difference(inDt));

    // 2) สาย X นาที (ตามภาพ)
    if (lateMinutes > 0) {
      late String lateText;//late ใน Dart แปลว่า “เดี๋ยวค่อยกำหนดค่าให้ทีหลัง” (แต่สัญญาว่า ก่อนใช้งานจริง จะต้องมีค่าแน่นอน)

      if(lateMinutes >= 60){
        lateText = "สาย ${_formatMinutesToHourMinute(lateMinutes)} ชม.";
      }
      else{
        lateText = "สาย $lateMinutes นาที";
      }

      return {
        "bgColor": badgeColor,
        "statusText": lateText,
        "statusBg": const Color(0xFFFFF3CD),//เหลืองอ่อนมาก
        "statusFg": const Color(0xFFB26A00),//เหลืองทองเข้ม
        "duration": "$duration ชั่วโมง",
        "statusIconAsset": "assets/images/warning_outline__attendance.svg",
      };
    }

    return {
      "bgColor": badgeColor,
      "statusText": "ตรงเวลา",
      "statusBg": const Color(0xFFE6F4EA),//เขียวอ่อนมาก
      "statusFg": const Color(0xFF1E8E3E),//เขียวเข้ม
      "duration": "$duration ชั่วโมง",
      "statusIconAsset": "assets/images/check_circle__attendance.svg", // <- ต้องมีไฟล์นี้ (ถ้าไม่มีดูหมายเหตุด้านล่าง)
    };
  }

  //ใส่ loading/error ก่อนสร้าง ListView
  Widget _buildHistoryList() {
    if(_loading){
      return const Center(child:CircularProgressIndicator());
    }
    if(_error != null){
      return Center(child: Text("โหลดข้อมูลไม่สำเร็จ:  $_error"));
    }
    if(_items.isEmpty){
      return const Center(child: Text("ไม่มีข้อมูล"));
    }

    //ก้อนสีขาว ใหญ่
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListView.separated( //ใช้ทำลิสต์ที่มีเส้น/ช่องว่างคั่นระหว่าง item แต่ละอัน
        //itemCount: _mock.length, //fake data
        itemCount: _items.length,//from api database
        separatorBuilder: (_,__) => const Divider(height: 20),
        itemBuilder: (context,index){
          //final item = _mock[index];//fake data
          final item = _items[index];//แบบอ่านจาก model api database เลย

          //แปลง String วันที่ให้กลายเป็น DateTime
          //final date = DateTime.parse(item["date"]); // 2026-12-24
          final date = item.date; //parse

          //ถ้าตอนนี้เป็นแถวแรก (index = 0) ให้ prevDate เป็น null
          // แต่ถ้าไม่ใช่แถวแรก ให้เอาวันที่ของแถวก่อนหน้า (index-1) มาแปลงเป็น DateTime แล้วเก็บไว้ใน prevDate
          //final prevDate = index == 0 ? null : DateTime.parse(_items[index - 1]["date"]);
          final prevDate = index == 0 ? null : _items[index - 1].date;

          // เช็คว่า "รายการปัจจุบัน" เป็นเดือน/ปีใหม่เมื่อเทียบกับ "รายการก่อนหน้า" หรือไม่
          // - ถ้า prevDate เป็น null (แถวแรก) -> ถือว่าเป็นเดือนใหม่
          // - หรือถ้าเดือนต่างกัน -> เดือนใหม่
          // - หรือถ้าปีต่างกัน -> ปีใหม่ (นับเป็นเดือนใหม่ด้วย)
          // ใช้เพื่อแสดงหัวข้อเดือน/ปี (เช่น "ม.ค. 2027") ตอนเปลี่ยนเดือน
          final isNewMonth = prevDate == null ||
              prevDate.month != date.month ||
              prevDate.year != date.year;

          final day = date.day.toString();
          // ใช้ dow จาก API ถ้ามี ไม่มีก็คำนวณจาก date เป็น fallback
          // dow = (item["dow"] as String?) ?? _thaiDowFromDate(date);
          final dow = item.dow ?? _thaiDowFromDate(date);

          //final timeIn = (item["checkIn"] ?? "--:--").toString();
          //final timeOut = item["checkOut"] == null ? "--:--" : item["checkOut"].toString();
          final timeIn = item.checkIn ?? "--:--";
          final timeOut = item.checkOut ?? "--:--";

          final ui = _computeUi(
            dow: dow,
            timeIn: timeIn,
            timeOut: timeOut,
          );

          final row = _historyRow(
            day: day,
            dow: dow,
            badgeColor: ui["bgColor"],
            timeIn: timeIn,
            timeOut: timeOut,
            statusText: ui["statusText"],
            statusBg: ui["statusBg"],
            statusFg: ui["statusFg"],
            duration: ui["duration"],
            statusIconAsset: ui["statusIconAsset"],
          );

          /*
          2026-12-24 (แถวแรก) → isNewMonth = true → แสดงหัวข้อ “ธันวาคม 2569” + row
          2026-12-23 → เดือน/ปีเหมือนแถวก่อน → isNewMonth = false → เข้า if แล้ว return row ทันที (ไม่โชว์หัวข้อซ้ำ)
          2027-01-24 (เดือน/ปีเปลี่ยน) → isNewMonth = true → แสดงหัวข้อ “มกราคม 2570” + row
           */
          if (!isNewMonth) return row;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _monthYearLabel(date),//"ธันวาคม 2569"
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              row,//history
            ],
          );
        },
      ),
    );
  }

  Widget _historyRow({
    required String day,
    required String dow,
    required Color badgeColor,
    required String timeIn,
    required String timeOut,
    required String statusText,
    required Color statusBg,
    required Color statusFg,
    required String duration,
    required String statusIconAsset,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Container(
          //ก้อน DOW Ex. 22 วันพุธ
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(14)
          ),
          child: Column(
            children: [
              Text(day, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              //const SizedBox(height: 0.005),//gap
              Text(dow, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(width: 20),//gap
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Row(
                        children: [
                          //icon
                          SvgPicture.asset(
                            statusIconAsset,
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(statusFg, BlendMode.srcIn), // ให้ไอคอนเป็นสีเดียวกับตัวหนังสือ
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusFg,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    //Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                    //icon
                    SvgPicture.asset(
                      'assets/images/clock_attendance.svg',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(duration, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ],
            )
        )
      ],
    );
  }

  void _openFilterPopup(){
    //เรียกใช้ popup เพื่อแสดงหน้าต่างตัวกรองขึ้นมา
    PushPopup(
      //ตั้งชื่อหัวข้อบน pop up
      title: "ตัวกรอง",
      buttonLabel: "บันทึก",

      buttonAction: (context){
        // ปิด popup (ย้อนกลับหน้า/ปิด dialog ที่อยู่บนสุด)
        Navigator.pop(context);
      },

      // เนื้อหาด้านใน popup (ตัว UI ที่ให้เลือกวัน)
       builder: (BuildContext context) {
        return CalendarTimePopupContent(
          // callback ที่ถูกเรียกเมื่อผู้ใช้กด Save ภายใน content นี้
          // โดยจะส่งค่าที่ผู้ใช้เลือกกลับมา: start, end, checkIn, checkOut
            onSave: (start,end,checkIn,checkOut){
              // setState เพื่ออัปเดตค่าที่เก็บใน State และให้ UI รีเฟรช
              setState(() {
                // ถ้ามีการเลือกวันเริ่มต้น (ไม่เป็น null) ให้แปลงเป็นข้อความ
                if (start != null){
                  // แปลง DateTime -> "วัน/เดือน/ปี" และ +543 เพื่อเป็นปี พ.ศ.
                  startDate = "${start.day}/${start.month}/${start.year + 543}";
                }

                // ถ้ามีการเลือกวันสิ้นสุด (ไม่เป็น null) ให้แปลงเป็นข้อความ
                if (end != null) {
                  // แปลง DateTime -> "วัน/เดือน/ปี" และ +543 เพื่อเป็นปี พ.ศ.
                  endDate = "${end.day}/${end.month}/${end.year + 543}";
                }

                // ในฟิลเตอร์นี้ "ไม่เอาเวลา"
                // ดังนั้นไม่ต้อง set ค่า startTime / endTime
              });

              // ปิด Popup หลังจากบันทึกค่าเสร็จ
              Navigator.pop(context);
            }
        );
      }
    ).showPopup(context);
  }
}

