import 'package:attendance_system/features/main_feature/statistic/attendance_statistic.dart';
import 'package:attendance_system/features/main_feature/statistic/leave_statistic.dart';
import 'package:attendance_system/features/main_feature/statistic/working_day.dart';
import 'package:attendance_system/features/main_feature/statistic/working_hour.dart';
import 'package:attendance_system/features/settings/personnel_info/choose_personnel.dart';
import 'package:attendance_system/services/personnel_info/personnel_info_model.dart';
import 'package:attendance_system/services/personnel_info/personnel_statistic_service.dart';
import 'package:attendance_system/services/statistic/statistic_model.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/animation/animated_widget.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater_promax.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:attendance_system/shared/widgets/utils/wheel_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonnelStatistic extends StatefulWidget {

  final PersonnelInfoModel personnel;

  /// ฝังเนื้อหาลงในคอลัมน์ขวาของ master-detail แทนการเป็นหน้าเต็ม
  /// — ไม่มีแถบหัวและปุ่ม back เพราะรายการทางซ้ายทำหน้าที่นำทางแทนแล้ว
  final bool embedded;

  const PersonnelStatistic({super.key, required this.personnel, this.embedded = false});

  @override
  State<StatefulWidget> createState() => _PersonnelStatisticState();

}

class _PersonnelStatisticState extends State<PersonnelStatistic> {

  PersonnelInfoModel? personnel;

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
  void initState() {
    super.initState();
    personnel = widget.personnel;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _body(context);

    return AppScaffold(
        header: Header.subHeader(
            context,
            title: 'สถิติ',
            onBack: () {
              Navigator.of(context).pop(personnel);
            }
        ),
      content: _body(context),
    );
  }

    /// เนื้อหาล้วนๆ ไม่รวมแถบหัว — ใช้ทั้งตอนเป็นหน้าเต็มและตอนถูกฝัง
    /// ในคอลัมน์ขวาของ master-detail
    Widget _body(BuildContext context) {
      return SafeArea(
          child: Container(
            color: AppColors.backgroundColor,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: ServiceUpdaterProMax(
                        requests: [
                          () => PersonnelStatisticService().getStatistic(personnelId: personnel!.id, year: yearFilter),
                          () => PersonnelStatisticService().getWorkingHour(personnelId: personnel!.id),
                          () => PersonnelStatisticService().getFilterRange(personnelId: personnel!.id),
                        ],
                        onSuccess: (index, data) {

                          setState(() {
                            switch(index) {
                              case 0: {
                                statistic = StatisticModel.fromJson(data);
                              }
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
                          return Column(
                              spacing: 13,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE3E3E3),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 14),
                                    child: SeparatorCard(
                                      children: [
                                        UserInfoButton(
                                          icon: Image.network(
                                            personnel!.avatarUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Image.asset('assets/images/profile.png'),
                                          ),
                                          title: personnel!.nameTH,
                                          subTitle: personnel!.nameEN,
                                          roles: [
                                            ...personnel!.roles,
                                            Role(id: '0000000000', name: personnel!.initRole, color: Color(0xFF535353))
                                          ],
                                          onPressed: () {
                                            PushPopup(
                                                title: 'เลือกบุคลากร',
                                                fit: FlexFit.tight,
                                                maxHeight: 700,
                                                scroll: false,
                                                builder: (BuildContext context) {
                                                  return ChoosePersonnel(
                                                      onChoose: (personnel) {
                                                        setState(() {
                                                          this.personnel = personnel;

                                                          allowFilterStart = null;
                                                          allowFilterEnd = null;
                                                          statistic = null;
                                                          workingHour = null;
                                                        });
                                                        trigger(-1);
                                                      }
                                                  );
                                                }
                                            ).showPopup(context);
                                          },
                                        )
                                      ],
                                    )
                                ),
                                Column(
                                  spacing: 13,
                                  children: [
                                    /// First Part
                                    Column(
                                      spacing: 6,
                                      children: [
                                        /// Filter
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6),
                                          child: InkWell(
                                            onTap: () {
                                              if (allowFilterStart != null && allowFilterEnd != null) {
                                                int selectedIndex = getYears(
                                                    allowFilterStart, allowFilterEnd)
                                                    .indexOf(yearFilter.year);
                                                PushPopup(
                                                  title: 'เลือกปีงบประมาณ',
                                                  buttonLabel: 'บันทึก',
                                                  fit: FlexFit.tight,
                                                  maxHeight: 650,
                                                  buttonAction: (context) {
                                                    Navigator.of(context).pop();
                                                    setState(() {
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
                                                                            leftItems: getYears(allowFilterStart, allowFilterEnd).map((e) => (e + 543).toString()).toList(),
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
                                            child: Row(
                                              spacing: 6,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/filter.svg',
                                                  colorFilter: ColorFilter.mode(Color(0xFF2C2C2C), BlendMode.srcIn),
                                                ),
                                                Text(
                                                    'ปีงบประมาณ ${yearFilter.year + 543}',
                                                    style: TextStyle(
                                                      color: Color(0xFF2C2C2C),
                                                      fontWeight: FontWeight.bold
                                                    )
                                                ),
                                                SvgPicture.asset(
                                                  'assets/images/icon_next.svg',
                                                  colorFilter: ColorFilter.mode(Color(0xFF2C2C2C), BlendMode.srcIn),
                                                ),
                                                if (getState(0) == ServiceUpdaterProMaxState.loading)
                                                  CupertinoActivityIndicator(),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Column(
                                          spacing: 13,
                                          children: [
                                            /// Working Day
                                            WorkingDay(statistic),

                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFEAEAEA),
                                                borderRadius: BorderRadius.circular(22),
                                              ),
                                              child: Column(
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
                                    WorkingHour(workingHour)
                                  ],
                                ),
                              ]
                          );
                        }
                      )
                    )
                  )
                ]
              )
            )
          )
        );
    }
}
