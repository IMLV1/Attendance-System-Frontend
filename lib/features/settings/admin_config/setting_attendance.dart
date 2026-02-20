import 'package:attendance_system/core/data/api/config_attendance_time_api.dart';
import 'package:attendance_system/core/data/entities/config_attendance_time_model.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/animation/animated_widget.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/floating_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/toggle_switch.dart';
import 'package:attendance_system/shared/widgets/utils/wheel_selector.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

Future<Response> mockData() async {
  await Future.delayed(const Duration(milliseconds: 5000));

  return Response(
      requestOptions: RequestOptions(path: '/mock/user'),
      statusCode: 200,
      data: {
        'auto-checkout': true,
        'cutoff-time': {
          'hour': 0,
          'minute': 0,
        },
        'check-in-time': {
          'hour': 8,
          'minute': 30,
        },
        'check-out-time': {
          'hour': 16,
          'minute': 30,
        },
        'check-in-leave-time': {
          'hour': 13,
          'minute': 0,
        },
        'check-out-leave-time': {
          'hour': 12,
          'minute': 0,
        },
      }
  );
}

class SettingAttendance extends StatefulWidget {
  const SettingAttendance({super.key});

  @override
  State<StatefulWidget> createState() => _SettingAttendanceState();
}

class _SettingAttendanceState extends State<SettingAttendance> {

  final List<String> hours = List.generate(24, (index) => index.toString().padLeft(2, '0'),);
  final List<String> minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'),);

  String focused1 = '';
  String focused2 = '';
  String focused3 = '';

  ConfigAttendanceTimeModel? initData;
  ConfigAttendanceTimeModel? data;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context, title: 'ตั้งค่าการลงชื่อเข้า-ออกงาน',
          onBack: () {
            if (data == null || initData!.isSame(data!)) {
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
                          request: () => ConfigAttendanceTimeService().update(data!),
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
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          spacing: 13,
                          children: [
                            SeparatorCard(
                              separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                              children: [
                                Column(
                                  children: [
                                    IconTextValueButton(
                                      arrow: false,
                                      icon: 'sunraise.svg',
                                      label: 'เวลาการตัดรอบวัน',
                                      value: data!.cutoffTime.format(context),
                                      onPressed: () {
                                        setState(() {
                                          focused1 = (focused1 != 'cut-off') ? 'cut-off' : '';
                                        });
                                      },
                                    ),
                                    AnimatedSizeWidget(
                                        enable: focused1 == 'cut-off',
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                                                child: Divider(height: 0)
                                            ),

                                            WheelSelector(
                                              height: 150,
                                              // Data Sources
                                              leftItems: hours,
                                              rightItems: minutes,

                                              // Initial Positions
                                              initialLeftIndex: data!.cutoffTime.hour,
                                              initialRightIndex: data!.cutoffTime.minute,

                                              // Handle Changes
                                              onChanged: (leftIndex, rightIndex) {
                                                setState(() {
                                                  data = data!.copyWith(cutoffTime: TimeOfDay(
                                                      hour: leftIndex,
                                                      minute: rightIndex ?? 0
                                                  ));
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                    )
                                  ],
                                )
                              ],
                            ),
                            SeparatorCard(
                              separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                              children: [
                                Column(
                                  children: [
                                    IconTextValueButton(
                                      arrow: false,
                                      icon: 'check-in-time.svg',
                                      label: 'เวลาเข้างาน',
                                      value: data!.checkInTime.format(context),
                                      onPressed: () {
                                        setState(() {
                                          focused2 = (focused2 != 'check-in') ? 'check-in' : '';
                                        });
                                      },
                                    ),
                                    AnimatedSizeWidget(
                                        enable: focused2 == 'check-in',
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                                                child: Divider(height: 0)
                                            ),

                                            WheelSelector(
                                              height: 150,
                                              // Data Sources
                                              leftItems: hours,
                                              rightItems: minutes,

                                              // Initial Positions
                                              initialLeftIndex: data!.checkInTime.hour,
                                              initialRightIndex: data!.checkInTime.minute,

                                              // Handle Changes
                                              onChanged: (leftIndex, rightIndex) {
                                                setState(() {
                                                  data = data!.copyWith(checkInTime: TimeOfDay(
                                                      hour: leftIndex,
                                                      minute: rightIndex ?? 0
                                                  ));
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconTextValueButton(
                                      arrow: false,
                                      icon: 'check-out-time.svg',
                                      label: 'เวลาออกงาน',
                                      value: data!.checkOutTime.format(context),
                                      onPressed: () {
                                        setState(() {
                                          focused2 = (focused2 != 'check-out') ? 'check-out' : '';
                                        });
                                      },
                                    ),
                                    AnimatedSizeWidget(
                                        enable: focused2 == 'check-out',
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                                                child: Divider(height: 0)
                                            ),

                                            WheelSelector(
                                              height: 150,
                                              // Data Sources
                                              leftItems: hours,
                                              rightItems: minutes,

                                              // Initial Positions
                                              initialLeftIndex: data!.checkOutTime.hour,
                                              initialRightIndex: data!.checkOutTime.minute,

                                              // Handle Changes
                                              onChanged: (leftIndex, rightIndex) {
                                                setState(() {
                                                  data = data!.copyWith(checkOutTime: TimeOfDay(
                                                      hour: leftIndex,
                                                      minute: rightIndex ?? 0
                                                  ));
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SeparatorCard(
                              separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                              children: [
                                ToggleSwitch(
                                  icon: 'auto_checkout.svg',
                                  label: 'เช็คเอ้าท์อัตโนมัติเมื่อถึงกำหนดลาครึ่งวันเย็น',
                                  value: data!.autoCheckout,
                                  onChanged: (value) {
                                    setState(() {
                                      data = data!.copyWith(autoCheckout: value);
                                    });
                                  },
                                ),
                                Column(
                                  children: [
                                    IconTextValueButton(
                                      arrow: false,
                                      icon: 'check-in-time.svg',
                                      label: 'เวลาเข้างานเมื่อลาครึ่งวันเช้า',
                                      value: data!.checkInLeaveTime.format(context),
                                      onPressed: () {
                                        setState(() {
                                          focused3 = (focused3 != 'check-in-leave') ? 'check-in-leave' : '';
                                        });
                                      },
                                    ),
                                    AnimatedSizeWidget(
                                        enable: focused3 == 'check-in-leave',
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                                                child: Divider(height: 0)
                                            ),

                                            WheelSelector(
                                              height: 150,
                                              // Data Sources
                                              leftItems: hours,
                                              rightItems: minutes,

                                              // Initial Positions
                                              initialLeftIndex: data!.checkInLeaveTime.hour,
                                              initialRightIndex: data!.checkInLeaveTime.minute,

                                              // Handle Changes
                                              onChanged: (leftIndex, rightIndex) {
                                                setState(() {
                                                  data = data!.copyWith(checkInLeaveTime: TimeOfDay(
                                                      hour: leftIndex,
                                                      minute: rightIndex ?? 0
                                                  ));
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconTextValueButton(
                                      arrow: false,
                                      icon: 'check-out-time.svg',
                                      label: 'เวลาออกงานเมื่อลาครึ่งวันเย็น',
                                      value: data!.checkOutLeaveTime.format(context),
                                      onPressed: () {
                                        setState(() {
                                          focused3 = (focused3 != 'check-out-leave') ? 'check-out-leave' : '';
                                        });
                                      },
                                    ),
                                    AnimatedSizeWidget(
                                        enable: focused3 == 'check-out-leave',
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                                                child: Divider(height: 0)
                                            ),

                                            WheelSelector(
                                              height: 150,
                                              // Data Sources
                                              leftItems: hours,
                                              rightItems: minutes,

                                              // Initial Positions
                                              initialLeftIndex: data!.checkOutLeaveTime.hour,
                                              initialRightIndex: data!.checkOutLeaveTime.minute,

                                              // Handle Changes
                                              onChanged: (leftIndex, rightIndex) {
                                                setState(() {
                                                  data = data!.copyWith(checkOutLeaveTime: TimeOfDay(
                                                      hour: leftIndex,
                                                      minute: rightIndex ?? 0
                                                  ));
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                    )
                                  ],
                                )
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
    );
  }
}
