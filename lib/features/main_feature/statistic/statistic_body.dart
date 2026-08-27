import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/features/main_feature/statistic/attendance_statistic.dart';
import 'package:attendance_system/features/main_feature/statistic/leave_statistic.dart';
import 'package:attendance_system/features/main_feature/statistic/working_day.dart';
import 'package:attendance_system/features/main_feature/statistic/working_hour.dart';
import 'package:attendance_system/services/statistic/statistic_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/animation/animated_widget.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater_promax.dart';
import 'package:attendance_system/shared/widgets/utils/wheel_selector.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// เนื้อหาหน้าสถิติ — ใช้ร่วมกันระหว่าง `/statistic` (ของตัวเอง) กับแท็บสถิติ
/// ในหน้า "ข้อมูลบุคลากร" (ของคนอื่น)
///
/// 🚩 (2026-08-27) เดิมสองหน้านี้เป็นโค้ดคนละชุดที่ก๊อปกันมา ~300 บรรทัด ต่างกัน
/// จริงๆ แค่ service ที่ยิงกับการ์ดหัวเรื่องเท่านั้น พอ Phase 3 ไปปรับ `/statistic`
/// ให้จัดวางตามขนาดจอ (ตัวกรองปีเป็นการ์ดในแถวเดียวกับ KPI, สองการ์ดสถิติวางคู่
/// กันบนจอกว้าง) อีกหน้าก็ค้างอยู่กับหน้าตาเดิมทันที — ผู้ใช้เห็นหน้าสถิติสองแบบ
/// ในแอปเดียวกัน
///
/// ยุบมาไว้ที่เดียวเพื่อไม่ให้เกิดอาการนี้อีก: แก้ครั้งเดียวได้ทั้งสองหน้า
///
/// **การเปลี่ยนคน** ให้ผู้เรียกส่ง `key` ที่ผูกกับ id ของคนนั้น (`ValueKey(id)`)
/// widget จะถูกสร้างใหม่ทั้งตัว = state เก่าหายไปเอง แล้ว `fetchOnInit` ยิงชุดใหม่
/// ให้ ไม่ต้องมี logic เคลียร์ค่าเดิมทีละฟิลด์ซึ่งเคยลืมบางตัวได้ง่าย
class StatisticBody extends StatefulWidget {

  const StatisticBody({
    super.key,
    required this.requests,
    this.header,
  });

  /// สร้างชุดคำขอตามปีงบประมาณที่เลือกอยู่ — ลำดับต้องเป็น
  /// `[สถิติ, ชั่วโมงทำงาน, ช่วงปีที่เลือกได้]` เพราะ `onSuccess` แยกด้วย index
  final List<Future<Response> Function()> Function(DateTime yearFilter) requests;

  /// การ์ดที่วางเหนือทุกอย่างในสกรอลล์เดียวกัน
  final Widget? header;

  @override
  State<StatisticBody> createState() => _StatisticBodyState();
}

class _StatisticBodyState extends State<StatisticBody> {

  StatisticModel? statistic;
  WorkingHourModel? workingHour;
  DateTime yearFilter = DateTime(DateTime.now().year);

  DateTime? allowFilterStart;
  DateTime? allowFilterEnd;

  List<int> getYears(DateTime? start, DateTime? end) {
    if (start == null || end == null) return [];

    int startYear = start.year;
    int endYear = end.year;

    // สลับค่าถ้าปีเริ่มต้นมากกว่าปีสิ้นสุด
    if (startYear > endYear) {
      int temp = startYear;
      startYear = endYear;
      endYear = temp;
    }

    // สร้าง Array ของปี
    return [for (int y = startYear; y <= endYear; y++) y];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      alignment: Alignment.topCenter,
      child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                  child: Column(
                    children: [
                      ServiceUpdaterProMax(
                        requests: widget.requests(yearFilter),
                        onSuccess: (index, data) {
                          setState(() {
                            switch(index) {
                              case 0: statistic = StatisticModel.fromJson(data);
                              case 1: workingHour = WorkingHourModel.fromJson(data);
                              case 2: {
                                allowFilterStart = DateTime.tryParse(data['start']);
                                allowFilterEnd = DateTime.tryParse(data['end']);
                              }
                            }
                          });
                        },
                        fetchOnInit: true,
                        builder: (trigger, getState) {
                          /// การ์ดตัวกรองปีงบประมาณ — ใช้ตัวเดียวกันทุกขนาดจอ
                          final filterCard = Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: InkWell(
                                      onTap: () {
                                        if (statistic != null) {
                                          int selectedIndex = getYears(
                                            allowFilterStart, allowFilterEnd)
                                            .indexOf(yearFilter.year);
                                          PushPopup(
                                            title: 'เลือกปีงบประมาณ',
                                            buttonLabel: 'บันทึก',
                                            fit: FlexFit.tight,
                                            maxHeight: 650,
                                            buttonAction: (context) {
                                              setState(() {
                                                Navigator.of(context).pop();
                                                int year = getYears(
                                                    allowFilterStart,
                                                    allowFilterEnd)[selectedIndex];
                                                yearFilter = DateTime(year);
                                              });
                                              trigger(-1);
                                            },
                                            builder: (context) {
                                              bool opened = false;

                                              return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return SeparatorCard(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            IconTextValueButton(
                                                              icon: 'budget_year.svg',
                                                              label: 'ปีงบประมาณ',
                                                              value: (getYears(
                                                                  allowFilterStart,
                                                                  allowFilterEnd)[selectedIndex] +
                                                                  543)
                                                                  .toString(),
                                                              onPressed: () {
                                                                setState(() {
                                                                  opened =
                                                                  !opened;
                                                                });
                                                              },
                                                            ),
                                                            AnimatedSizeWidget(
                                                                enable: opened,
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                        padding: EdgeInsetsGeometry
                                                                            .symmetric(
                                                                            horizontal: 15),
                                                                        child: Divider(
                                                                            height: 0)
                                                                    ),
                                                                    WheelSelector(
                                                                      looping: false,
                                                                      height: 150,
                                                                      initialLeftIndex: selectedIndex,
                                                                      leftItems: getYears(
                                                                          allowFilterStart,
                                                                          allowFilterEnd)
                                                                          .map((
                                                                          e) =>
                                                                          (e +
                                                                              543)
                                                                              .toString())
                                                                          .toList(),
                                                                      onChanged: (
                                                                          left,
                                                                          right) {
                                                                        setState(() {
                                                                          selectedIndex =
                                                                              left;
                                                                        });
                                                                      },
                                                                    )
                                                                  ],
                                                                )
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    );
                                                  }
                                              );
                                            },
                                          ).showPopup(context);
                                        }
                                      },
                                      child: SeparatorCard(
                                        borderRadius: BorderRadius.circular(22),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFEAEAEA),
                                                    borderRadius:
                                                        BorderRadius.circular(22),
                                                  ),
                                                  padding: EdgeInsets.all(6),
                                                  child: SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    // ใช้ไอคอนเดียวกับหัวข้อ
                                                    // "ปีงบประมาณ" ในตัวเลือกปี
                                                    // และหน้าตั้งค่าปีงบประมาณ
                                                    // แทน filter.svg ทั่วไป
                                                    child: SvgPicture.asset(
                                                      'assets/images/budget_year.svg',
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                              Color(0xFF2C2C2C),
                                                              BlendMode.srcIn),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'ปีงบประมาณ',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFF7F7F7F)),
                                                      ),
                                                      Row(
                                                        spacing: 6,
                                                        children: [
                                                          Text(
                                                            '${yearFilter.year + 543}',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              color: AppColors
                                                                  .primaryColor,
                                                            ),
                                                          ),
                                                          if (getState(0) ==
                                                              ServiceUpdaterProMaxState
                                                                  .loading)
                                                            CupertinoActivityIndicator(
                                                                radius: 7),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SvgPicture.asset(
                                                  'assets/images/icon_next.svg',
                                                  colorFilter: ColorFilter.mode(
                                                      Color(0xFF2C2C2C),
                                                      BlendMode.srcIn),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );

                          return Column(
                            spacing: 13,
                            children: [
                              // การ์ดบอกว่ากำลังดูสถิติของใคร — มีเฉพาะหน้า
                              // "ข้อมูลบุคลากร" หน้าสถิติของตัวเองไม่ต้องมี
                              if (widget.header != null) widget.header!,

                              /// First Part
                              Column(
                                spacing: 6,
                                children: [
                                  Column(
                                    spacing: 13,
                                    children: [
                                      /// Working Day
                                      //
                                      // แถวบนสุด — ตัวกรองปีงบประมาณเป็นการ์ด
                                      // ใบแรกของแถวเดียวกัน เพราะมันคือบริบทของ
                                      // ทุกตัวเลขในหน้าอยู่แล้ว
                                      //
                                      // component ชุดเดียวกันทั้ง 3 แพลตฟอร์ม
                                      // ต่างแค่การจัดวาง — จอกว้างเรียงสามใบใน
                                      // แถวเดียว จอแคบเอาตัวกรองขึ้นบนเต็มความ
                                      // กว้างแล้ววางสองใบที่เหลือข้างกันใต้มัน
                                      // (สามใบในแถวเดียวบนจอ 390 จะแคบเกินไป)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFEAEAEA),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Responsive.isCompact(context)
                                            ? Column(
                                                spacing: 10,
                                                children: [
                                                  filterCard,
                                                  WorkingDay(statistic,
                                                      bare: true),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Expanded(child: filterCard),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    flex: 2,
                                                    child: WorkingDay(statistic,
                                                        bare: true),
                                                  ),
                                                ],
                                              ),
                                      ),

                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFEAEAEA),
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        // 🚩 (Phase 3) สองการ์ดนี้เป็นโรคเดียวกับหน้าอื่น:
                                        // การ์ด "การลางาน" ชื่อประเภทลาอยู่ x≈600 ตัวเลข
                                        // อยู่ x≈1360 ห่างกัน 660px หนักสุดในหน้า
                                        // (ดู PHASE3_PAGE_DESIGN.md หัวข้อ /statistic)
                                        //
                                        // วางคู่กันบนจอกว้าง คอลัมน์เหลือข้างละ ~540
                                        // ระยะจากชื่อถึงตัวเลขลดเหลือราว 180px ใกล้เคียง
                                        // กับบนมือถือที่อ่านรู้เรื่องอยู่แล้ว — ไม่ต้อง
                                        // ออกแบบการ์ดใหม่เลย แค่เปลี่ยนที่วาง
                                        // จอที่ไม่ใช่มือถือกว้างพอวางคู่กันทั้งหมด — iPad แนวตั้ง
                                        // (1032) ก็เหลือคอลัมน์ละ ~500 เท่ากับ
                                        // desktop ที่จำกัดไว้ 1100
                                        // 🚩 (Phase 3) ยืดสองการ์ดให้สูงเท่ากัน
                                        // ถึงจะอ่านเป็นสี่เหลี่ยมคู่ที่ลงตัว
                                        // เดิมปล่อยตามเนื้อหาจริงจึงสูงไม่เท่ากัน
                                        //
                                        // ต้องห่อ IntrinsicHeight ก่อน เพราะ Row
                                        // ตัวนี้อยู่ใน scroll view ที่ความสูงไม่
                                        // จำกัด — `stretch` เพียวๆ จะส่ง
                                        // constraint เป็น infinity แล้ว assert
                                        // ตอน layout (แพงขึ้นนิดหน่อย แต่มีแค่
                                        // สองลูก คุ้มกับความเรียบร้อยที่ได้)
                                        child: !Responsive.isCompact(context)
                                            ? IntrinsicHeight(
                                                child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                spacing: 13,
                                                children: [
                                                  Expanded(
                                                    child: AttendanceStatistic(
                                                        statistic,
                                                        fill: true),
                                                  ),
                                                  Expanded(
                                                    child: LeaveStatistic(
                                                        statistic,
                                                        fill: true),
                                                  ),
                                                ],
                                              ))
                                            : Column(
                                                spacing: 13,
                                                children: [
                                                  /// Attendance Statistic
                                                  AttendanceStatistic(statistic),

                                                  /// Leave Statistic
                                                  LeaveStatistic(statistic),
                                                ],
                                              ),
                                      )
                                    ],
                                  )
                                ],
                              ),

                              /// Working Hour
                              //
                              // 🚩 (Phase 3) การ์ดสรุป "ชั่วโมงทำงานรวม/เฉลี่ย"
                              // ต้องอยู่กับกราฟเสมอ เพราะตัวเลขเปลี่ยนตามปุ่ม
                              // ทั้งหมด/สัปดาห์/เดือน/ปี ที่อยู่เหนือกราฟ
                              // (เคยลองย้ายขึ้นไปรวมกับ KPI วันทำงานด้านบน แล้ว
                              // กลายเป็นว่ากดปุ่มกลางหน้าแต่เลขบนหัวเปลี่ยน งงกว่าเดิม)
                              //
                              // กว้างเต็มเท่าแถวข้างบน — เคยบีบไว้ 760 กันกราฟ
                              // ยืดจนโล่ง แต่ตอนนี้การ์ดสรุปกินฝั่งขวาไปแล้ว
                              // กราฟจึงไม่ได้ยืดเต็มอยู่ดี และการบีบทำให้ขอบ
                              // กล่องไม่ตรงกับสองกล่องข้างบน
                              WorkingHour(workingHour)
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                )
              )
            )
          ]
        )
    );
  }
}
