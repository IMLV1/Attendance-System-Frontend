import 'package:attendance_system/services/system_config/budget_year/budget_year_model.dart';
import 'package:attendance_system/services/system_config/budget_year/budget_year_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/floating_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/service_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/wheel_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingBudgetYear extends StatefulWidget {
  const SettingBudgetYear({super.key});

  @override
  State<StatefulWidget> createState() => _SettingBudgetYearState();

}

class _SettingBudgetYearState extends State<SettingBudgetYear> {

  final List<String> months = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
  ];

  int initMonthIndex = 0;
  int initDayIndex = 0;

  int selectedMonthIndex = 0;
  int selectedDayIndex = 0;

  // 1. ประกาศตัวแปรเก็บ list วันที่ไว้ข้างนอก build
  late List<String> dayItems;

  @override
  void initState() {
    super.initState();
    // 2. สร้างค่าเริ่มต้นครั้งแรก
    _updateDayItems();
  }

  // ฟังก์ชันคำนวณจำนวนวัน
  int getDaysInMonth(int monthIndex) {
    if (monthIndex == 1) return 28;
    if ([3, 5, 8, 10].contains(monthIndex)) return 30;
    return 31;
  }

  // 3. แยกฟังก์ชันสร้าง List ออกมา
  void _updateDayItems() {
    final int daysCount = getDaysInMonth(selectedMonthIndex);
    dayItems = List.generate(
      daysCount,
          (index) => '${index + 1}',
    );
  }

  @override
  Widget build(BuildContext context) {
    // ❌ ลบการสร้าง List ใน build ออก

    return AppScaffold(
        header: Header.subHeader(context,
          title: 'ตั้งค่าปีงบประมาณ',
          onBack: () {
            if (initDayIndex == selectedDayIndex && initMonthIndex == selectedMonthIndex) {
              Navigator.of(context).pop();
            } else {
              FloatingPopup(

                  title: 'บันทึกการเปลี่ยนแปลง',
                  description: 'คุณยืนยันที่จะบันทึกการเปลี่ยนแปลงนี้หรือไม่',

                  buttons: (void Function(String) setError, BuildContext context1) {
                    return [

                      FloatingPopupButton(
                          foregroundColor: Colors.red,
                          onPressed: () {
                            Navigator.of(context1).pop();
                            Navigator.pop(context);
                          },
                          text: 'ละทิ้ง'
                      ),

                      FloatingServicePopupButton(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          onSuccess: () {
                            Navigator.of(context1).pop();
                            Navigator.pop(context);
                          },
                          text: 'บันทึก',
                          request: () => BudgetYearService().update(selectedDayIndex + 1, selectedMonthIndex + 1),
                          setError: setError
                      )
                    ];
                  }
              ).showPopup(context);
            }
          }
        ),
        content: SafeArea(
            child: Container(
                color: AppColors.backgroundColor,
                alignment: Alignment.topCenter,
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 20, bottom: 20),
                    child: Column(
                        children: [
                          Expanded(
                            child: ServiceLoader(
                              request: () => BudgetYearService().getData(),
                              onSuccess: (jsonData) {
                                setState(() {
                                  final data = BudgetYearModel.fromJson(jsonData);
                                  setState(() {

                                    selectedDayIndex = data.day - 1;
                                    selectedMonthIndex = data.month - 1;

                                    initDayIndex = selectedDayIndex;
                                    initMonthIndex = selectedMonthIndex;

                                  });
                                });
                              },
                              builder: () {
                                return SingleChildScrollView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: SeparatorCard(
                                      separatorPadding: EdgeInsetsGeometry.symmetric(
                                          horizontal: 15),
                                      children: [
                                        IconTextValueButton(
                                            icon: 'budget_year.svg',
                                            label: 'วันที่เริ่มต้นปีงบประมาณ',
                                            value: '${selectedDayIndex +
                                                1} ${months[selectedMonthIndex]}'
                                        ),
                                        SizedBox(
                                          height: 150,
                                          child: WheelSelector(
                                            leftItems: months,
                                            rightItems: dayItems,
                                            // ✅ ส่งตัวแปรเดิมเข้าไป
                                            initialLeftIndex: selectedMonthIndex,
                                            initialRightIndex: selectedDayIndex,
                                            onChanged: (leftIndex, rightIndex) {
                                              setState(() {
                                                // 4. เช็คว่าเดือนเปลี่ยนหรือไม่?
                                                if (selectedMonthIndex != leftIndex) {
                                                  selectedMonthIndex = leftIndex;
                                                  // ถ้าเดือนเปลี่ยน ค่อยสร้าง List วันที่ใหม่
                                                  _updateDayItems();
                                                  // รีเซ็ตวันที่เป็น 0 กันตกขอบ (หรือจะใช้ logic เดิมก็ได้)
                                                  selectedDayIndex = 0;
                                                } else {
                                                  // ถ้าแค่เลื่อนวัน ไม่ต้องสร้าง List ใหม่
                                                  selectedDayIndex = rightIndex ?? 0;
                                                }
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    )
                                );
                              }
                            )
                          )
                        ]
                    )
                )
            )
        )
    );
  }
}