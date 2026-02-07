import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter_svg/svg.dart';

import '../../shared/widgets/utils/separator_card.dart';
import '../../shared/widgets/utils/text_button.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPage();
}

class _LeaveRequestPage extends State<LeaveRequestPage> {
  String? leaveType;

  bool flag = true;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppScaffold(
      header: Header.mainHeader(
        context,
        title: 'ส่งคำขอลางาน',
        subTitle: 'Leave Request',
        iconPath: 'icon_leave.svg',
        iconColor: Colors.white
      ),
      content: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(15),
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
              Container(
                padding: EdgeInsets.all(16) ,
                decoration: BoxDecoration(
                  color: Color(0xFFEAEAEA),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    SeparatorCard(
                      children: [
                        TextButton(
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
                        )
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
                                if (leaveType != null) ...[
                                  Text(
                                    /// TODO: Calculate ( Limit Day - Current Day )
                                    'คุณใช้สิทธิ์$leaveTypeไปแล้ว 2 วัน และยังเหลือสิทธิ์ลาป่วยอีก 58 วัน',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                                InkWell(
                                  onTap: () {
                                    /// TODO: Direct Go to Somethings
                                  },
                                  child: Text(
                                    'ดูข้อมูลเพิ่มเติม',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    /// TODO: Select Day On Here

                    SizedBox(height: 5),
                    TextField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'ระบุหมายเหตุ...',
                        hintStyle: TextStyle(
                          color: Color(0xFF7D7D7D),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    SeparatorCard(
                      separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                      children: [
                        IconTextButton(
                          icon: 'icon_upload_file.svg',
                          label: 'อัพโหลดไฟล์',
                          color: AppColors.primaryColor,
                          onPressed: () {
                            /// TODO: Upload File
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'ยังไม่ได้อัพโหลดไฟล์',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF7D7D7D), // สีจาง
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 3),
              SizedBox(
                width: double.infinity,
                height: 48,
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
              ),
              /// TODO: Flag is Over Limit Day
              if (flag && leaveType != null) ...[
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
              ],
              SizedBox(height: 3),
              Row(
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
              ),
              SeparatorCard(
                separatorPadding: EdgeInsetsGeometry.only(left: 70, right: 15),
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
              )
            ],
          ),
        )
      ),
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
                separatorPadding: EdgeInsetsGeometry.only(left: 70, right: 15),
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