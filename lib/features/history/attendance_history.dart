import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/services/history/attendance_history_model.dart';
import 'package:attendance_system/services/history/attendance_history_service.dart';
import 'package:attendance_system/services/system_config/attendance_request/config_attendance_request_model.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_model.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/popup/date_filter_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater_promax.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<StatefulWidget> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  DateTime? filterStart;
  DateTime? filterEnd;

  List<AttendanceHistoryModel> _items = [];

  int _stdInHour = 0;
  int _stdInMinute = 0;

  @override
  Widget build(BuildContext context) {

    ConfigAttendanceTimeModel? setting = context.watch<AuthState>().timeConfig;

    _stdInHour = setting?.checkInTime.hour ?? 0;
    _stdInMinute = setting?.checkInTime.minute ?? 0;

    // setting?.checkInLeaveTime

    return AppScaffold(
      header: Header.subHeader(context, title: "บันทึกการเข้างาน"),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      spacing: 13,
                      children: [
                        ServiceUpdaterProMax(
                            requests: [

                              // {date: 2026-02-18, dow: จันทร์, checkIn: 09:30, checkOut: null}

                              // Utils.mockResponse(
                              //   data: [
                              //     {
                              //       'date': '2026-03-02',
                              //       'dow': 'จันทร์',
                              //       'checkIn': '01:07',
                              //       'checkOut': null,
                              //     }
                              //   ]
                              // )

                              () => AttendanceHistoryService().fetchHistory(
                                startDate: filterStart == null ? null : _toYmd(filterStart!),
                                endDate: filterEnd == null ? null : _toYmd(filterEnd!),
                              )
                            ],
                            onSuccess: (index, data) {
                              setState(() {
                                _items = AttendanceHistoryModel.getList(data);
                                _items.sort((a, b) => b.date.compareTo(a.date));
                              });
                            },
                            fetchOnInit: true,
                            builder: (trigger, getState) {
                              // จัดกลุ่มข้อมูลตามเดือน/ปี เตรียมไว้สำหรับสร้าง UI
                              final Map<String, List<AttendanceHistoryModel>> groupedItems = {};
                              for (var item in _items) {
                                final label = _monthYearLabel(item.date);
                                groupedItems.putIfAbsent(label, () => []).add(item);
                              }

                              return Column(
                                spacing: 13,
                                children: [
                                  // ================= UI ส่วนที่ 1: กล่องตัวกรอง (Filter) =================
                                  InkWell(
                                    onTap: () {
                                      DateFilterPopup(
                                          currentDateFrom: filterStart,
                                          currentDateTo: filterEnd,
                                          onSubmit: (start, end) {
                                            setState(() {
                                              filterStart = start;
                                              filterEnd = end;
                                            });
                                            trigger(0);
                                          }
                                      ).showPopup(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        color: const Color(0xFFE9E9E9),
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
                                              if (getState(0) == ServiceUpdaterProMaxState.loading)
                                                const CupertinoActivityIndicator(radius: 7),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Row(
                                              spacing: 10,
                                              children: [
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
                                                              _formatDateDisplay(filterStart),
                                                              style: const TextStyle(fontSize: 14),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                ),
                                                Container(width: 1.5, height: 40, color: const Color(0xFFB1B1B1)),
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
                                    Column(
                                      spacing: 15,
                                      children: groupedItems.entries.map((entry) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 8,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Text(
                                                entry.key,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SeparatorCard(
                                              separatorPadding: const EdgeInsets.only(left: 95, right: 15),
                                              children: entry.value.map((item) {
                                                // ดึงและเตรียมข้อมูลก่อนแสดงผลแต่ละแถว
                                                final day = item.date.day.toString();
                                                final dow = item.dow ?? _thaiDowFromDate(item.date);
                                                final timeIn = item.checkIn ?? "--:--";
                                                final timeOut = item.checkOut ?? "--:--";
                                                final ui = _computeUi(dow: dow, timeIn: timeIn, timeOut: timeOut);

                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
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

  String _toYmd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  String _formatDateDisplay(DateTime? date) {
    if (date == null) return "---";
    return "${date.day}/${date.month}/${date.year + 543}";
  }

  String _thaiMonth(int m) {
    const months = ['', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'];
    if (m < 1 || m > 12) return '';
    return months[m];
  }

  String _monthYearLabel(DateTime d) => "${_thaiMonth(d.month)} ${d.year + 543}";

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

  bool _isMissingTime(String t) {
    final s = t.trim();
    return s.isEmpty || s == '--:--' || s == '--.--' || s == '-';
  }

  DateTime _parseTime(String t) {
    final s = t.trim().replaceAll('.', ':');
    final parts = s.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(2000, 1, 1, h, m);
  }

  String _formatHourMinute(Duration d) {
    if (d.isNegative) return '--:--';
    final totalMin = d.inMinutes;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  String _formatMinutesToHourMinute(int minutes) {
    if (minutes <= 0) return '0:00';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

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

  Map<String, dynamic> _computeUi({
    required String dow,
    required String timeIn,
    required String timeOut,
  }) {
    final badgeColor = _badgeColorByDow(dow);
    final inMissing = _isMissingTime(timeIn);
    final outMissing = _isMissingTime(timeOut);

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

    final DateTime inDt = _parseTime(timeIn);
    final DateTime outDt = _parseTime(timeOut);
    final stdDt = DateTime(2000, 1, 1, _stdInHour, _stdInMinute);

    final lateMinutes = inDt.difference(stdDt).inMinutes;
    final duration = _formatHourMinute(outDt.difference(inDt));

    if (lateMinutes > 0) {
      late String lateText;
      if (lateMinutes >= 60) {
        lateText = "สาย ${_formatMinutesToHourMinute(lateMinutes)} ชม.";
      } else {
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