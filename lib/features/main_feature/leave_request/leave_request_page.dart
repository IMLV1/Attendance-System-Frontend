import 'dart:io';
import 'dart:math';

import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/widgets/utils/separator_card.dart';
import '../../../shared/widgets/utils/text_button.dart' as utils;

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPage();
}

class _LeaveRequestPage extends State<LeaveRequestPage> {

  String? leaveType;
  bool flag = true;

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
            padding: EdgeInsets.only(
              left: 10, right: 10, top: 20, bottom: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      spacing: 13,
                      children: [
                        Column(
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
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10) ,
                              decoration: BoxDecoration(
                                color: Color(0xFFEAEAEA),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 10,
                                children: [
                                  Column(
                                    spacing: 6,
                                    children: [
                                      SeparatorCard(
                                        children: [
                                          utils.TextButton(
                                            label: leaveType ?? 'เลือกประเภทการลา',
                                            color: leaveType == null ? Color(0xFF7D7D7D) : Colors.black,
                                            onPressed: () async {
                                              /// TODO: Select Leave Request
                                              final result = await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => const LeaveType(),
                                                ),
                                              );
                                              if (result != null) {
                                                setState(() {
                                                  leaveType = result;
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      if (leaveType != null)
                                        Row(
                                          spacing: 6,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 15,
                                              width: 15,
                                              child: SvgPicture.asset(
                                                  'assets/images/iicon.svg'
                                              ),
                                            ),
                                            Expanded(
                                              child: Wrap(
                                                spacing: 5,
                                                children: [
                                                  if (leaveType != null)
                                                    RichText(
                                                      text: TextSpan(
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                            'คุณใช้สิทธิ์$leaveTypeไปแล้ว 2 วัน และยังเหลือสิทธิ์ลา$leaveTypeอีก 58 วัน ',
                                                          ),
                                                          TextSpan(
                                                            text: 'ดูข้อมูลเพิ่มเติม',
                                                            style: const TextStyle(
                                                              color: Colors.blue,
                                                              decoration: TextDecoration.underline,
                                                            ),
                                                            recognizer: TapGestureRecognizer()
                                                              ..onTap = () {
                                                                // TODO: Navigate somewhere
                                                              },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  TextField(
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'ระบุหมายเหตุ...',
                                      hintStyle: TextStyle(
                                          color: Color(0xFF7D7D7D),
                                          fontSize: 15
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 11,
                                        horizontal: 15,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(22),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  SeparatorCard(
                                    separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
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
                                        style: const MenuStyle(
                                          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                                          elevation: WidgetStatePropertyAll(0),
                                        ),
                                        menuChildren: [
                                          TweenAnimationBuilder<double>(
                                            tween: Tween(begin: 0, end: 1),
                                            duration: const Duration(milliseconds: 250),
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
                                                      Flexible(child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(file.name,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w800
                                                              )
                                                          ),
                                                          Text('ขนาด ${_formatBytes(file.size)}',
                                                              style: TextStyle(
                                                                  color: Color(0xFF7D7D7D),
                                                                  fontWeight: FontWeight.normal
                                                              )
                                                          ),
                                                        ],
                                                      )),
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
                          ],
                        )

                        /*SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: submit
                            },
                            icon: SvgPicture.asset(
                              'assets/images/icon_send.svg',
                              height: 18,
                              width: 18,
                              colorFilter: ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: Text(
                              'ส่ง',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),*/
                        /*if (flag && leaveType != null) ...[
                          Row(
                            spacing: 6,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 15,
                                width: 15,
                                child: SvgPicture.asset(
                                  'assets/images/icon_alert.svg',
                                  colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
                                ),
                              ),
                              Expanded(
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                  child: Wrap(
                                    spacing: 4,
                                    children: [
                                      Text(
                                        'คุณได้ใช้สิทธิ์การ$leaveTypeครบตามจำนวนที่กำหนดแล้ว หากคำขอนี้ได้รับการอนุมัติจำนวนวันลาของคุณจะเกินสิทธิ์ 2 วัน ซึ่งอาจส่งผลต่อการคำนวณตัวชี้วัดผลการปฏิบัติงาน',
                                      ),
                                      Text(
                                          'กรุณากดปุ่มอีกครั้ง',
                                          style: TextStyle(fontWeight: FontWeight.bold)
                                      ),
                                      Text('เพื่อดำเนินการต่อ',),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],*/
                        /*Row(
                          spacing: 5,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: SvgPicture.asset(
                                'assets/images/icon_time.svg',
                              ),
                            ),
                            Text(
                              'ติดตามสถานะ',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {

                              },
                              child: Text(
                                'ดูทั้งหมด',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.primaryColor
                                ),
                              ),
                            )
                          ],
                        ),*/
                        /*SeparatorCard(
                          separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 15),
                          children: [
                            AppButton(
                              icon: 'icon_success.svg',
                              iconColor: Color(0xFF00B646),
                              title: '17/09/2020 - 18/03/2021',
                              subTitle: 'หมายเลขคำขอ: LEV000000065012',
                              onPressed: () {
                                /// TODO: Open Pop-Up
                              },
                            ),
                            AppButton(
                              icon: 'icon_success.svg',
                              iconColor: Color(0xFF00B646),
                              title: '17/09/2020 - 18/03/2021',
                              subTitle: 'หมายเลขคำขอ: LEV000000065012',
                              onPressed: () {
                                /// TODO: Open Pop-Up
                              },
                            ),
                          ],
                        )*/
                      ],
                    )
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

class LeaveType extends StatelessWidget {
  const LeaveType({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'เลือกประเภทการลา'
      ),
      content: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SeparatorCard(
                separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 15),
                children: [
                  AppButton(
                    icon: 'icon_sick.svg',
                    title: 'ลาป่วย',
                    onPressed: () {
                      Navigator.pop(context, 'ลาป่วย');
                    },
                  ),
                  AppButton(
                    icon: 'icon_leave_personal.svg',
                    title: 'ลากิจส่วนตัว',
                    onPressed: () {
                      Navigator.pop(context, 'ลากิจส่วนตัว');
                    },
                  ),
                  AppButton(
                    icon: 'icon_vacation.svg',
                    title: 'ลาพักผ่อน',
                    onPressed: () {
                      Navigator.pop(context, 'ลาพักผ่อน');
                    },
                  ),
                  AppButton(
                    icon: 'icon_maternity_leave.svg',
                    title: 'ลาคลอดบุตร',
                    onPressed: () {
                      Navigator.pop(context, 'ลาคลอดบุตร');
                    },
                  ),
                  AppButton(
                    icon: 'icon_leave_assist_childbirth.svg',
                    title: 'ลาช่วยเหลือภริยาคลอดบุตร',
                    onPressed: () {
                      Navigator.pop(context, 'ลาช่วยเหลือภริยาคลอดบุตร');
                    },
                  ),
                  AppButton(
                    icon: 'icon_taking_care_child.svg',
                    title: 'ลากิจเพื่อเลี้ยงดูบุตร',
                    onPressed: () {
                      Navigator.pop(context, 'ลากิจเพื่อเลี้ยงดูบุตร');
                    },
                  ),
                ],
              )
            ],
          ),
        )
      )
    );
  }
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

Future<PlatformFile?> _pickDocumentOrImage(BuildContext context) async {
  return await showModalBottomSheet<PlatformFile>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Upload PDF"),
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );

                Navigator.pop(context, result?.files.first);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Upload Photo"),
              onTap: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);

                if (image != null) {
                  final bytes = await image.readAsBytes();

                  final file = PlatformFile(
                    name: image.name,
                    size: bytes.length,
                    path: image.path,
                    bytes: bytes,
                  );

                  Navigator.pop(context, file);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

int _generateRandomNumber(int digits) {
  if (digits <= 0) {
    throw ArgumentError('Digits must be greater than 0');
  }

  final random = Random();

  int min = pow(10, digits - 1).toInt();   // smallest number with N digits
  int max = pow(10, digits).toInt() - 1;   // largest number with N digits

  return min + random.nextInt(max - min + 1);
}