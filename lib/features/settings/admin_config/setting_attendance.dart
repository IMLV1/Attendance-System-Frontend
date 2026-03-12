import 'package:attendance_system/core/utils/navigation_guard.dart';
import 'package:attendance_system/features/settings/admin_config/admin_config_utils.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_model.dart';
import 'package:attendance_system/services/system_config/attendance_time/config_attendance_time_service.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/toggle_switch.dart';
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

  final List<String> hours = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  final List<String> minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'));

  @override
  Widget build(BuildContext context) {
    final isDirty = data != null && !initData!.isSame(data!);

    // Update global navigation guard
    context.read<NavigationGuard>().update(
      isDirty: isDirty,
      onSave: () => ConfigAttendanceTimeService().update(data!),
      onDiscard: () {
        context.read<NavigationGuard>().reset();
        Navigator.of(context).pop();
      },
    );

    return AppScaffold(
        header: Header.subHeader(
            context, title: 'ตั้งค่าเวลาเข้างาน-ออกงาน',
            onBack: () {
              Navigator.of(context).maybePop();
            }
        ),
        content: PopScope(
          canPop: data == null || initData!.isSame(data!),
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            AdminConfigUtils.showSaveConfirmation(
              context: context,
              onSave: () => ConfigAttendanceTimeService().update(data!),
              onDiscard: () {
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
                                          IconTextValueButton(
                                              icon: 'icon_attendance_time.svg',
                                              label: 'เวลาเข้างานปกติ',
                                              value: data!.checkInTime.format(context)
                                          ),
                                          WheelSelector(
                                            height: 150,
                                            leftItems: hours,
                                            rightItems: minutes,
                                            initialLeftIndex: data!.checkInTime.hour,
                                            initialRightIndex: data!.checkInTime.minute,
                                            onChanged: (h, m) {
                                              setState(() {
                                                data = data!.copyWith(checkInTime: TimeOfDay(hour: h, minute: m ?? 0));
                                              });
                                            },
                                          ),
                                          IconTextValueButton(
                                              icon: 'icon_attendance_time.svg',
                                              label: 'เวลาออกงานปกติ',
                                              value: data!.checkOutTime.format(context)
                                          ),
                                          WheelSelector(
                                            height: 150,
                                            leftItems: hours,
                                            rightItems: minutes,
                                            initialLeftIndex: data!.checkOutTime.hour,
                                            initialRightIndex: data!.checkOutTime.minute,
                                            onChanged: (h, m) {
                                              setState(() {
                                                data = data!.copyWith(checkOutTime: TimeOfDay(hour: h, minute: m ?? 0));
                                              });
                                            },
                                          ),
                                          IconTextValueButton(
                                              icon: 'icon_attendance_time.svg',
                                              label: 'เวลาสาย (เริ่มนับสาย)',
                                              value: data!.checkInLeaveTime.format(context)
                                          ),
                                          WheelSelector(
                                            height: 150,
                                            leftItems: hours,
                                            rightItems: minutes,
                                            initialLeftIndex: data!.checkInLeaveTime.hour,
                                            initialRightIndex: data!.checkInLeaveTime.minute,
                                            onChanged: (h, m) {
                                              setState(() {
                                                data = data!.copyWith(checkInLeaveTime: TimeOfDay(hour: h, minute: m ?? 0));
                                              });
                                            },
                                          ),
                                          IconTextValueButton(
                                              icon: 'icon_attendance_time.svg',
                                              label: 'เวลาออกก่อน',
                                              value: data!.checkOutLeaveTime.format(context)
                                          ),
                                          WheelSelector(
                                            height: 150,
                                            leftItems: hours,
                                            rightItems: minutes,
                                            initialLeftIndex: data!.checkOutLeaveTime.hour,
                                            initialRightIndex: data!.checkOutLeaveTime.minute,
                                            onChanged: (h, m) {
                                              setState(() {
                                                data = data!.copyWith(checkOutLeaveTime: TimeOfDay(hour: h, minute: m ?? 0));
                                              });
                                            },
                                          ),
                                          IconTextValueButton(
                                              icon: 'icon_attendance_time.svg',
                                              label: 'เวลาตัดรอบวัน',
                                              value: data!.cutoffTime.format(context)
                                          ),
                                          WheelSelector(
                                            height: 150,
                                            leftItems: hours,
                                            rightItems: minutes,
                                            initialLeftIndex: data!.cutoffTime.hour,
                                            initialRightIndex: data!.cutoffTime.minute,
                                            onChanged: (h, m) {
                                              setState(() {
                                                data = data!.copyWith(cutoffTime: TimeOfDay(hour: h, minute: m ?? 0));
                                              });
                                            },
                                          ),
                                          ToggleSwitch(
                                            icon: 'icon_attendance_time.svg',
                                            label: 'บันทึกออกงานอัตโนมัติ',
                                            value: data!.autoCheckout,
                                            onChanged: (value) {
                                              setState(() {
                                                data = data!.copyWith(autoCheckout: value);
                                              });
                                            },
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
