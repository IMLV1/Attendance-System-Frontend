

import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/utils/popup/push_popup.dart';
import '../../shared/widgets/utils/calendar.dart';


class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<StatefulWidget> createState() => _AttendanceHistoryState();

}

class _AttendanceHistoryState extends State<AttendanceHistory> {
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
                      onTap: _openFilterPopup,// Go To
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

  //ตัวอย่าง (ข้อมูลปลอม) เอาไว้โชว์ UI ก่อน
  //from database
  final List<Map<String,dynamic>> _mock = [
    {
      "day": "24",
      "dow": "ศุกร์",
      "in": "09.30",
      "out": "18.30"
    },
    {
      "day": "23",
      "dow": "พฤหัสบดี",
      "in": "07.30",
      "out": "22.30"
    },
    {
      "day": "22",//from database
      "dow": "พุธ",// dow = day of week //from database
      "in": "08.30", //from database
      "out": "--:--", //from database
    },
    {
      "day": "21",
      "dow": "อังคาร",
      "in": "08:42",
      "out": "16:30",
    },
    {
      "day": "20",
      "dow": "จันทร์",
      "in": "08:30",
      "out": "21:30",
    },
  ];

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

  /// duration แบบ H.MM (ชั่วโมง.นาที) ตามภาพ เช่น 7.48, 13.00
  String _formatHourDotMinute(Duration d) {
    if (d.isNegative) return '--.--';
    final totalMin = d.inMinutes;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '$h.${m.toString().padLeft(2, '0')}';
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
    final duration = _formatHourDotMinute(outDt.difference(inDt));

    // 2) สาย X นาที (ตามภาพ)
    if (lateMinutes > 0) {
      return {
        "bgColor": badgeColor,
        "statusText": "สาย $lateMinutes นาที",
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

  Widget _buildHistoryList() {
    //ก้อนสีขาว ใหญ่
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListView.separated( //ใช้ทำลิสต์ที่มีเส้น/ช่องว่างคั่นระหว่าง item แต่ละอัน
        itemCount: _mock.length,
        separatorBuilder: (_,__) => const Divider(height: 20),
        itemBuilder: (context,index){
          final item = _mock[index];

          final ui = _computeUi(
            dow: item["dow"],
            timeIn: item["in"],
            timeOut: item["out"],
          );

          return _historyRow(
            day: item["day"],
            dow: item["dow"],
            badgeColor: ui["bgColor"],
            timeIn: item["in"],
            timeOut: item["out"],
            statusText: ui["statusText"],
            statusBg: ui["statusBg"],
            statusFg: ui["statusFg"],
            duration: ui["duration"],
            statusIconAsset: ui["statusIconAsset"],
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
          width: 64*1.25,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(14)
          ),
          child: Column(
            children: [
              Text(day, style: const TextStyle(fontSize: 30*1.25, fontWeight: FontWeight.w700)),
              const SizedBox(height: 1),//gap
              Text(dow, style: const TextStyle(fontSize: 14*1.25, color: Colors.black54)),
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
                    Text("เข้างาน  ", style: TextStyle(fontSize: 12*1.25, color: Colors.grey.shade600)),
                    Text(timeIn, style: const TextStyle(fontSize: 15*1.25, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 11),
                    Text("|", style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(width: 11),
                    Text("ออกงาน  ", style: TextStyle(fontSize: 12*1.25, color: Colors.grey.shade600)),
                    Text(timeOut, style: const TextStyle(fontSize: 15*1.25, fontWeight: FontWeight.w700)),
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
                            width: 16*1.25,
                            height: 16*1.25,
                            colorFilter: ColorFilter.mode(statusFg, BlendMode.srcIn), // ให้ไอคอนเป็นสีเดียวกับตัวหนังสือ
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12*1.25,
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
                      width: 16*1.25,
                      height: 16*1.25,
                    ),
                    const SizedBox(width: 6),
                    Text(duration, style: TextStyle(fontSize: 12*1.25, color: Colors.grey.shade700)),
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
                  startDate = "${start.day}/${start.month}/${start.year}";
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

