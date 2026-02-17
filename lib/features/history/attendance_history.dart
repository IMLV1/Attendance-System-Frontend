

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
  final List<Map<String,dynamic>> _mock = [
    {
      "day": "22",
      "dow": "พุธ",// dow = day of week
      "bgColor": const Color(0xFFEAF5EE), // สีพื้นหลังของกล่องวันที่ด้านซ้าย //green พาสเทล
      "in": "08.30",
      "out": "--:--",
      "statusText": "ไม่สมบูรณ์",
      "statusBg": const Color(0xFFFFE5E5), // สีพื้นหลังของชิปสถานะ // ชมพูอ่อนมาก / แดงอ่อนพาสเทล (พื้นหลังแจ้งเตือนอ่อนๆ)
      "statusFg": const Color(0xFFD32F2F), // สีตัวหนังสือ + ไอคอนในชิปสถานะ //แดงเข้ม (แนวแดงเตือน/ผิดพลาด)
      "duration": "-- ชั่วโมง",
    },
    {
      "day": "21",
      "dow": "อังคาร",
      "bgColor": const Color(0xFFF7ECF1),
      "in": "08:42",
      "out": "16:30",
      "statusText": "สาย 12 นาที",
      "statusBg": const Color(0xFFFFF3CD),
      "statusFg": const Color(0xFFB26A00),
      "duration": "7.48 ชั่วโมง",
    },
    {
      "day": "20",
      "dow": "จันทร์",
      "bgColor": const Color(0xFFFFF3CD),
      "in": "08:30",
      "out": "21:30",
      "statusText": "ตรงเวลา",
      "statusBg": const Color(0xFFE6F4EA),
      "statusFg": const Color(0xFF1E8E3E),
      "duration": "13.00 ชั่วโมง",
    },
  ];

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
          return _historyRow(
            day: item["day"],
            dow: item["dow"],
            badgeColor: item["bgColor"],
            timeIn: item["in"],
            timeOut: item["out"],
            statusText: item["statusText"],
            statusBg: item["statusBg"],
            statusFg: item["statusFg"],
            duration: item["duration"]
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
                            'assets/images/error_outline__attendance.svg',
                            width: 16*1.25,
                            height: 16*1.25,
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

