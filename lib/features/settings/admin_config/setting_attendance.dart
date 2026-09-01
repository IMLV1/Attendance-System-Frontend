import 'package:attendance_system/core/utils/navigation_guard.dart';
import 'package:attendance_system/features/settings/admin_config/admin_config_utils.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_model.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_service.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/animation/animated_widget.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/wheel_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/theme/app_colors.dart';

class SettingAttendance extends StatefulWidget {
  const SettingAttendance({super.key});

  @override
  State<StatefulWidget> createState() => _SettingAttendanceState();
}

class _SettingAttendanceState extends State<SettingAttendance> {
  ConfigAttendanceTimeModel? initData;
  ConfigAttendanceTimeModel? data;

  bool _forcePop = false;
  int? _expandedIndex;

  final List<String> hours = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  final List<String> minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'));

  Widget _buildTimePickerItem({
    required int index,
    required String icon,
    required String label,
    required TimeOfDay time,
    required void Function(int h, int? m) onChanged,
  }) {
    final bool isOpened = _expandedIndex == index;
    return Column(
      children: [
        IconTextValueButton(
          icon: icon,
          label: label,
          value: time.format(context),
          arrow: false,
          onPressed: () {
            setState(() {
              _expandedIndex = isOpened ? null : index;
            });
          },
        ),
        AnimatedSizeWidget(
          enable: isOpened,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Divider(height: 0),
              ),
              WheelSelector(
                height: 150,
                leftItems: hours,
                rightItems: minutes,
                initialLeftIndex: time.hour,
                initialRightIndex: time.minute,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDirty = data != null && !initData!.isSame(data!);

    // Update global navigation guard
    context.read<NavigationGuard>().update(
      isDirty: isDirty,
      onSave: () => ConfigAttendanceTimeService().update(data!),
      onDiscard: () {
        setState(() => _forcePop = true);
        context.read<NavigationGuard>().reset();
        Navigator.of(context).pop();
      },
    );

    return AppScaffold(
      maxWidth: Responsive.widthFor(ContentShape.form),
        header: Header.subHeader(
            context, title: 'ตั้งค่าการลงชื่อเข้า-ออกงาน',
            onBack: () {
              Navigator.of(context).maybePop();
            }
        ),
        content: PopScope(
          canPop: _forcePop || (data == null || initData!.isSame(data!)),
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            AdminConfigUtils.showSaveConfirmation(
              context: context,
              onSave: () => ConfigAttendanceTimeService().update(data!),
              onDiscard: () {
                setState(() => _forcePop = true);
                Navigator.of(context).pop();
              },
              onNavigateBack: () {
                setState(() => _forcePop = true);
                Navigator.of(context).pop();
              },
            );
          },
          child: SafeArea(
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
                                  request: () => ConfigAttendanceTimeService().getData(),
                                  onSuccess: (jsonData) {
                                    setState(() {
                                      final data = ConfigAttendanceTimeModel.fromJson(jsonData);
                                      setState(() {
                                        this.data = data;
                                        initData = this.data;
                                      });
                                    });
                                  },
                                  builder: () {
                                    return SingleChildScrollView(
                                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      child: Column(
                                        spacing: 13,
                                        children: [
                                          SeparatorCard(
                                            separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                                            children: [
                                              _buildTimePickerItem(
                                                index: 0,
                                                icon: 'sunraise.svg',
                                                label: 'เวลาการตัดรอบวัน',
                                                time: data!.cutoffTime,
                                                onChanged: (h, m) {
                                                  setState(() {
                                                    data = data!.copyWith(cutoffTime: TimeOfDay(hour: h, minute: m ?? 0));
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          SeparatorCard(
                                            separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                                            children: [
                                              _buildTimePickerItem(
                                                index: 1,
                                                icon: 'check-in-time.svg',
                                                label: 'เวลาเข้างาน',
                                                time: data!.checkInTime,
                                                onChanged: (h, m) {
                                                  setState(() {
                                                    data = data!.copyWith(checkInTime: TimeOfDay(hour: h, minute: m ?? 0));
                                                  });
                                                },
                                              ),
                                              _buildTimePickerItem(
                                                index: 2,
                                                icon: 'check-out-time.svg',
                                                label: 'เวลาออกงาน',
                                                time: data!.checkOutTime,
                                                onChanged: (h, m) {
                                                  setState(() {
                                                    data = data!.copyWith(checkOutTime: TimeOfDay(hour: h, minute: m ?? 0));
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          SeparatorCard(
                                            separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                                            children: [
                                              // 🚩 (2026-09-01) ถอดสวิตช์ "เช็คเอ้าท์อัตโนมัติ" ออก
                                              // — ไม่มีโค้ดที่ทำงานตามนั้นเลยทั้งแอปและ backend
                                              // ตั้งไว้เท่าไหร่ก็ไม่มีผล นอกจากไปโชว์ข้อความใน
                                              // หน้าเช็คอินว่าระบบจะทำให้ ซึ่งทำให้คนไม่กดเอง
                                              //
                                              // ฟิลด์ `auto-checkout` **ยังอยู่ครบ**ใน DB / entity /
                                              // model / service ตั้งใจไม่ลบ เพื่อไม่ต้องทำ migration
                                              // ตอนกลับมาทำฟีเจอร์นี้จริง (ค่า default = false)
                                              _buildTimePickerItem(
                                                index: 3,
                                                icon: 'check-in-time.svg',
                                                label: 'เวลาเข้างานเมื่อลาครึ่งวันเช้า',
                                                time: data!.checkInLeaveTime,
                                                onChanged: (h, m) {
                                                  setState(() {
                                                    data = data!.copyWith(checkInLeaveTime: TimeOfDay(hour: h, minute: m ?? 0));
                                                  });
                                                },
                                              ),
                                              _buildTimePickerItem(
                                                index: 4,
                                                icon: 'check-out-time.svg',
                                                label: 'เวลาออกงานเมื่อลาครึ่งวันเย็น',
                                                time: data!.checkOutLeaveTime,
                                                onChanged: (h, m) {
                                                  setState(() {
                                                    data = data!.copyWith(checkOutLeaveTime: TimeOfDay(hour: h, minute: m ?? 0));
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                              )
                          )
                        ]
                    )
                )
            )
          )
        )
    );
  }
}
