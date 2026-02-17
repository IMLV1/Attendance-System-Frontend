import 'dart:math';

import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../shared/widgets/utils/icon_text_button.dart';
import '../../../shared/widgets/utils/separator_card.dart';
import '../../../shared/widgets/utils/services/service_updater.dart';

int _generateRandomNumber(int digits) {
  if (digits <= 0) {
    throw ArgumentError('Digits must be greater than 0');
  }

  final random = Random();

  int min = pow(10, digits - 1).toInt();   // smallest number with N digits
  int max = pow(10, digits).toInt() - 1;   // largest number with N digits

  return min + random.nextInt(max - min + 1);
}

String _formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return '0 B';

  const suffixes = ['B', 'kB', 'MB', 'GB'];
  int i = 0;
  double size = bytes.toDouble();

  while (size >= 1024 && i < suffixes.length - 1) {
    size /= 1024;
    i++;
  }

  return '${size.toStringAsFixed(decimals).replaceAll(RegExp(r'\.?0+$'), '')} ${suffixes[i]}';
}

class TimeRequestPage extends StatefulWidget {
  const TimeRequestPage({super.key});

  @override
  State<TimeRequestPage> createState() => _TimeRequestPage();
}

class _TimeRequestPage extends State<TimeRequestPage> {
  List<PlatformFile> allFiles = [];

  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.mainHeader(
        context,
        title: 'ส่งคำขอลางาน',
        subTitle: 'Leave Request',
        iconPath: 'icon_leave.svg',
        iconColor: Colors.white
      ),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(
              left: 10,
              right: 10,
              top: 20,
              bottom: 10
            ),
            child: Column(
              spacing: 6,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: SvgPicture.asset(
                        'assets/images/icon_req_lev.svg',
                      ),
                    ),
                    Text(
                      'รายละเอียดการลางาน',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
                InkWell(
                  onTap: () async {
                    PushPopup(
                      title: 'เลือกวันที่',
                      buttonLabel: 'บันทึก',
                      fit: FlexFit.tight,
                      buttonAction: (context) {
                        setState(() {
                          // ค่า _rangeStart และ _rangeEnd จะถูกเก็บไว้แล้ว
                        });

                        Navigator.pop(context);
                      },

                      builder: (_) => StatefulBuilder(
                        builder: (context, setStatePopup) {
                          DateTime focusedDay = DateTime.now();
                          DateTime? rangeStart;
                          DateTime? rangeEnd;

                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: TableCalendar(
                                  locale: 'th_TH',
                                  firstDay: DateTime(2020, 1, 1),
                                  lastDay: DateTime(3000, 12, 31),

                                  focusedDay: focusedDay,
                                  rangeStartDay: rangeStart,
                                  rangeEndDay: rangeEnd,

                                  rangeSelectionMode: RangeSelectionMode.enforced,

                                  headerStyle: const HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                  ),

                                  onRangeSelected: (start, end, focusedDay) {

                                    setStatePopup(() {
                                      rangeStart = start;
                                      rangeEnd = end;
                                      focusedDay = focusedDay;
                                    });
                                  },

                                  calendarStyle: const CalendarStyle(

                                    rangeHighlightColor: Color(0xFFE3F2FD),

                                    rangeStartDecoration: BoxDecoration(
                                      color: Color(0xFF4A80F0),
                                      shape: BoxShape.circle,
                                    ),

                                    rangeEndDecoration: BoxDecoration(
                                      color: Color(0xFF4A80F0),
                                      shape: BoxShape.circle,
                                    ),

                                    todayDecoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),

                                    todayTextStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),

                                    selectedDecoration: BoxDecoration(
                                      color: Color(0xFF4A80F0),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              SeparatorCard(
                                children: [

                                ],
                              )
                            ],
                          );
                        },
                      ),
                    ).showPopup(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFEAEAEA),
                      borderRadius: BorderRadius.circular(22)
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16)
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10
                                  ),
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                          'assets/images/calendar_in.svg',
                                          colorFilter: ColorFilter.mode(Color(0xFF5F5F5F), BlendMode.srcIn),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'จากวันที่',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                            )
                                          ),
                                          Text(
                                            '---',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                            )
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ),

                              Container(
                                width: 1.5,
                                height: 40,
                                color: Colors.grey[400],
                                margin: EdgeInsetsGeometry.symmetric(
                                  horizontal: 3
                                )
                              ),

                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10
                                  ),
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                          'assets/images/calendar_out.svg',
                                          colorFilter: ColorFilter.mode(
                                              Color(0xFF5F5F5F),
                                              BlendMode.srcIn
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ถึงวันที่',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                            )
                                          ),
                                          Text(
                                            '---',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                            )
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3
                                  ),
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                          'assets/images/clock_calendar.svg',
                                          colorFilter: ColorFilter.mode(
                                            Color(0xFF626262),
                                            BlendMode.srcIn
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'เวลาเข้างาน',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                            )
                                          ),
                                          Text(
                                            '---',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                            )
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              )
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3
                                  ),
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                          'assets/images/clock_calendar.svg',
                                          colorFilter: ColorFilter.mode(
                                            Color(0xFF626262),
                                            BlendMode.srcIn
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'เวลาออกงาน',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                            )
                                          ),
                                          Text(
                                            '---',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                              Color(0xFF626262)
                                            )
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              )
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: 2
                ),

                Container(
                  padding: EdgeInsets.all(12) ,
                  decoration: BoxDecoration(
                    color: Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(22)
                  ),
                  child: Column(
                    spacing: 10,
                    children: [
                      TextField(
                        maxLines: 1,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'ระบุหมายเหตุ...',
                          hintStyle: TextStyle(
                            color: Color(0xFF7D7D7D),
                            fontSize: 14
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none
                          ),
                        ),
                      ),
                      SeparatorCard(
                        separatorPadding: EdgeInsetsGeometry.only(
                          left: 45,
                          right: 15
                        ),
                        children: [
                          MenuAnchor(
                            controller: _menuController,
                            builder: (context, controller, child) {
                              return IconTextButton(
                                icon: 'icon_upload_file.svg',
                                label: 'อัพโหลดไฟล์',
                                color: AppColors.primaryColor,
                                onPressed: () {
                                  controller.open();
                                },
                              );
                            },
                            clipBehavior: Clip.none,
                            consumeOutsideTap: true,
                            style: MenuStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                              elevation: WidgetStatePropertyAll(0),
                            ),
                            menuChildren: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.18),
                                        blurRadius: 100,
                                        spreadRadius: 6,
                                        offset: Offset.zero,
                                      ),
                                    ],
                                  ),
                                  child: SeparatorCard(
                                    borderRadius: BorderRadius.circular(20),
                                    children: [
                                      IconTextButton(
                                        icon: 'photos_upload.svg',
                                        arrow: false,
                                        label: 'คลังรูปภาพ',
                                        onPressed: () async {
                                          _menuController.close();

                                          final picker = ImagePicker();
                                          final image = await picker.pickImage(source: ImageSource.gallery);

                                          if (image != null) {
                                            final bytes = await image.readAsBytes();

                                            final file = PlatformFile(
                                              name: 'IMG_${_generateRandomNumber(5)}',
                                              size: bytes.length,
                                              path: image.path,
                                              bytes: bytes,
                                            );

                                            setState(() {
                                              allFiles.add(file);
                                            });
                                          }
                                        },
                                      ),
                                      IconTextButton(
                                        icon: 'camera_upload.svg',
                                        arrow: false,
                                        label: 'ถ่ายรูป',
                                        onPressed: () async {
                                          _menuController.close();
                                          final picker = ImagePicker();
                                          final image = await picker.pickImage(source: ImageSource.camera);

                                          if (image != null) {
                                            final bytes = await image.readAsBytes();

                                            final file = PlatformFile(
                                              name: 'IMG_${_generateRandomNumber(5)}',
                                              size: bytes.length,
                                              path: image.path,
                                              bytes: bytes,
                                            );

                                            setState(() {
                                              allFiles.add(file);
                                            });
                                          }
                                        },
                                      ),
                                      IconTextButton(
                                        icon: 'file_upload.svg',
                                        arrow: false,
                                        label: 'เลือกไฟล์',
                                        onPressed: () async {
                                          _menuController.close();
                                          final result = await FilePicker.platform.pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: ['pdf'],
                                          );

                                          if (result != null) {
                                            setState(() {
                                              allFiles.add(result.files.first);
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsGeometry.all(10),
                            child: (allFiles.isEmpty) ? Padding(
                              padding: EdgeInsetsGeometry.all(5),
                              child: Text(
                                'ยังไม่ได้อัพโหลดไฟล์',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF7D7D7D), // สีจาง
                                ),
                              ),
                            ) : SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 5,
                                runSpacing: 7,
                                children: [
                                  ...allFiles.map((file) {
                                    return Container(
                                      constraints: BoxConstraints(
                                          maxWidth: 230
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFFBDBDBD), // stroke color
                                          width: 2, // stroke width
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsetsGeometry.all(5),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  file.name,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w800
                                                  )
                                                ),
                                                Text(
                                                  'ขนาด ${_formatBytes(file.size)}',
                                                  style: TextStyle(
                                                    color: Color(0xFF7D7D7D),
                                                    fontWeight: FontWeight.normal
                                                  )
                                                ),
                                              ],
                                            )
                                          ),
                                          InkWell(
                                            customBorder: CircleBorder(),
                                            onTap: () {
                                              setState(() {
                                                allFiles.remove(file);
                                              });
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(6),
                                              child: Icon(
                                                CupertinoIcons.xmark_circle_fill,
                                                size: 17,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    );
                                  })
                                ],
                              )
                            )
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 2),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ServiceUpdater(
                      request: () => getSomething(),
                      onSuccess: () {

                      },
                      builder: (trigger, state, errorMessage) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                // onPressed: (state != ServiceUpdatorState.loading &&
                                //     _nameController.text.trim().isNotEmpty)
                                //     ? () => trigger()
                                //     : null,
                                icon: SvgPicture.asset('assets/images/icon_send.svg', height: 18, width: 18, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                                label: Row(
                                  spacing: 10,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('ส่ง', style: TextStyle(fontSize: 16, color: Colors.white)),
                                    if (state == ServiceUpdatorState.loading)
                                      CupertinoActivityIndicator(color: Colors.white)
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor: Colors.grey,
                                  backgroundColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                              child: (state == ServiceUpdatorState.error) ?
                              Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
                                style: TextStyle(
                                    color: Colors.red
                                )
                              ) : SizedBox()
                            )
                          ],
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      )
    );
  }
}

Future<Response> getSomething() async {
  await Future.delayed(const Duration(milliseconds: 500));

  final mockData = {
    "dada": '5555'
  };

  return Response(
    requestOptions: RequestOptions(path: '55555'),
    data: mockData,
    statusCode: 200,
  );
}
