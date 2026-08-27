import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/services/approval/attendance/attendance_service.dart';
import 'package:attendance_system/services/notification/notification_service.dart';
import 'package:attendance_system/services/personnel_info/personnel_attendance_request_service.dart';
import 'package:attendance_system/services/time_request/time_request_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/service_signature_page.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../services/time_request/time_request_model.dart';
import '../../../shared/widgets/utils/animation/animated_widget.dart';
import '../../../shared/widgets/utils/downloader.dart';
import '../../../shared/widgets/utils/icon_text_button.dart';
import '../../../shared/widgets/utils/popup/file_preview_popup.dart';
import '../../../shared/widgets/utils/popup/floating_popup.dart';
import '../../../shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import '../../../shared/widgets/utils/utils.dart';

Future<Response> mockData() async {

  await Future.delayed(
    const Duration(milliseconds: 200),
  );

  return Response(

    requestOptions: RequestOptions(path: '/api/attendance_request/detail'),
    statusCode: 200,
    data: {

      'request-detail': {
        'date-from': '2026-02-18T18:00:45.621Z',
        'date-to': '2026-02-18T18:00:45.621Z',
        'time-start': '08:00',
        'time-end': '09:00',
        'remark': 'ปวดหัว อาเจียน เป็นไข้ ทิฟฟี่แผงสีเขียว',
        'evidence-files': [
          {
            'file-name': 'final algorithm.pdf',
            'file-url': 'https://drive.google.com/uc?export=download&id=1vlrDqDVuYZhqy8E3HQXf8DsxctgnYUCN',
            'file-type': 'pdf',
            'file-size': 3079943
          },
          {
            'file-name': 'IMG_3535.jpg',
            'file-url': 'https://media.discordapp.net/attachments/1339973422494515212/1466642651330777222/61346471-07C0-4AED-AF16-B46C7876F3D4.jpg?ex=69a11568&is=699fc3e8&hm=156a11fcf6d2687752a07202dac4988fd913061d0fe04c11b82df47b62994eab&=&format=webp&width=669&height=1189',
            'file-type': 'jpg',
            'file-size': 5434478723
          }
        ],
      },
      'approve-detail': {
        'status': 'rejected', // pending, approved, rejected
        'approve-role': 'คณบดี',
        'approver': 'ด้วยดี ตามไท',
        'reason': 'ดีมาก',
        'approve-date': '2026-02-01T08:00:00.000Z',
      }
    },
  );
}

String formatDateTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')} น.';
}

String _formatDate(DateTime? date) {
  if (date == null) return '---';
  return '${DateFormat.MMMd('th_TH').format(date)} ${date.year + 543}';
}

String _formatTime(TimeOfDay? time) {
  if (time == null) return '---';
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

class PersonnelAttendanceRequestDetail extends StatefulWidget {
  final String id;
  final int permissionLevel;
  final void Function() onApproved;
  final void Function() onRejected;

  const PersonnelAttendanceRequestDetail({
    super.key,
    required this.id,
    required this.permissionLevel,
    required this.onApproved,
    required this.onRejected,
  });

  @override
  State<PersonnelAttendanceRequestDetail> createState() {
    return _PersonnelAttendanceRequestDetailState();
  }
}

class _PersonnelAttendanceRequestDetailState extends State<PersonnelAttendanceRequestDetail> {

  AttendanceDetail? data;
  bool onSelect = false;
  String status = '';

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final auth = context.read<AuthState>();
    final setting = auth.attendanceConfig;

    return Padding(
        padding: EdgeInsets.only(
          // 🚩 (2026-08-27) จอมือถือกว้าง 393pt แต่โดนขอบกินไปสองชั้น
          // (หน้า + การ์ดสีเทา) เหลือให้เนื้อหาจริงไม่ถึง 330pt — บีบขอบหน้า
          // ลงบนจอเล็ก จอใหญ่ยังเว้นเท่าเดิมเพราะมีที่เหลือเฟือ
          top: 10,
          left: Responsive.isCompact(context) ? 14 : 20,
          right: Responsive.isCompact(context) ? 14 : 20,
        ),
        child: ServiceLoader(
            request: () {
              // return mockData();
              return PersonnelAttendanceRequestService().getDetail(widget.id);
            },
            onSuccess: (val) {
              print(data);
              setState(() {
                data = AttendanceDetail.fromJson(val);
              });
            },
            builder: () {
              // 🚩 แก้: ใช้ Stack แทน Column — เนื้อหารายละเอียด (scroll) คงขนาด/ตำแหน่งเดิมเสมอ
              // ไม่ยุบ/ขยับตาม keyboard เลย ส่วนกล่อง "ระบุเหตุผล" + ปุ่มอนุมัติ/ปฏิเสธ ลอยทับ
              // ด้านบนด้วย Positioned(bottom: viewInsets.bottom) แทน
              return Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          spacing: 13,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SeparatorCard(
                              borderRadius: BorderRadius.circular(22),
                              children: [
                                Column(
                                  children: [
                                    AppButton(
                                      icon: switch(data?.approveDetail.status) {
                                        'approved' => 'icon_success.svg',
                                        'rejected' => 'icon_cancel.svg',
                                        'overdue'  => 'icon_overdue.svg',
                                        'canceled' => 'icon_request_cancel.svg',
                                        _ => 'icon_pending.svg'
                                      },
                                      iconColor: switch(data?.approveDetail.status) {
                                        'approved' => Color(0xFF30D143),
                                        'rejected' => Color(0xFFE7000B),
                                        'overdue'  => Color(0xFF000000),
                                        'canceled' => Color(0xFFFFA652),
                                        _ => Color(0xFFE79E00)
                                      },
                                      title: switch(data?.approveDetail.status) {
                                        'approved' => 'อนุมัติแล้ว',
                                        'rejected' => 'ไม่อนุมัติ',
                                        'overdue'  => 'เลยกำหนดเวลา',
                                        'canceled' => 'ยกเลิก',
                                        _ => 'รอดำเนินการ'
                                      },
                                      weightTitle: FontWeight.w500,
// subTitle: data?.approveDetail.status == 'pending'
//     ? 'ตำแหน่งที่รับผิดชอบการอนุมัติ: ${data?.approveDetail.approveRole ?? '-'}'
//     : 'อนุมัติโดย ${data?.approveDetail.approver}' ?? '-',
                                      subTitle: switch(data?.approveDetail.status) {
                                        'approved' => 'อนุมัติโดย ${data?.approveDetail.approver}',
                                        'rejected' => 'อนุมัติโดย ${data?.approveDetail.approver}',
                                        'overdue'  => 'คำขอนี้เลยกำหนดเวลาอนุมัติแล้ว',
                                        'canceled' => 'คำขอนี้ถูกยกเลิกแล้ว',
                                        _ => 'ตำแหน่งที่รับผิดชอบการอนุมัติ: ${data?.approveDetail.approveRole ?? '-'}'
                                      },
                                      arrow: false,
                                      timeStamp: data?.approveDetail.approveDate != null
                                          ? formatDateTime(data!.approveDetail.approveDate!)
                                          : null,
                                      onPressed: () {
                                        setState(() {
                                          onSelect = !onSelect;
                                        });
                                      },
                                    ),
                                    AnimatedSizeWidget(
                                      enable: onSelect && !(data!.approveDetail.status == 'pending' || data!.approveDetail.status == 'overdue' || data!.approveDetail.status == 'canceled'),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 6,
                                        children: [
                                          Padding(
                                              padding: EdgeInsetsGeometry.only(right: 15, left: 60),
                                              child: Divider(height: 0)
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(left: 60, right: 15),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'เนื่องจาก:',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors.lightTextColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    data?.approveDetail.reason ?? '-',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    softWrap: true,
                                                  ),
                                                  SizedBox(height: 10)
                                                ],
                                              )
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: Color(0xFFEAEAEA)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppButton(
                                    icon: 'icon_time_request.svg',
                                    title: 'การเข้างาน - ออกงาน',
                                    bg: Colors.white,
                                    weightTitle: FontWeight.w500,
                                    subTitle: 'หมายเลขตำขอ ${widget.id}',
                                    arrow: false,
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 12),
                                      decoration: BoxDecoration(
                                          color: Color(0xFFEAEAEA),
                                          borderRadius: BorderRadius.circular(22)
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            spacing: 10,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: 10,
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
                                                              Expanded(
                                                                // 🚩 (2026-08-27) ต้องห่อ Expanded ไม่งั้น Column กว้างตามเนื้อหาตัวเอง
                                                                // แล้วล้นกรอบบนจอแคบ — เจอบน iPhone: "RIGHT OVERFLOWED BY 2.9 PIXELS"
                                                                // ตรงบรรทัด "4 ส.ค. 2569 เช้า" (ยาวกว่าที่มีให้อยู่ไม่กี่ px)
                                                                child: Column(
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
                                                                        _formatDate(data?.requestDetail.dateFrom),
                                                                        style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.black
                                                                        )
                                                                    ),
                                                                  ],
                                                                ),
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
                                                              horizontal: 10,
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
                                                              Expanded(
                                                                // 🚩 (2026-08-27) ต้องห่อ Expanded ไม่งั้น Column กว้างตามเนื้อหาตัวเอง
                                                                // แล้วล้นกรอบบนจอแคบ — เจอบน iPhone: "RIGHT OVERFLOWED BY 2.9 PIXELS"
                                                                // ตรงบรรทัด "4 ส.ค. 2569 เช้า" (ยาวกว่าที่มีให้อยู่ไม่กี่ px)
                                                                child: Column(
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
                                                                        _formatDate(data?.requestDetail.dateTo),
                                                                        style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.black
                                                                        )
                                                                    ),
                                                                  ],
                                                                ),
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
                                                            borderRadius: BorderRadius.circular(25),
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
                                                                        _formatTime(data?.requestDetail.timeStart),
                                                                        style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.black
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
                                                            borderRadius: BorderRadius.circular(22),
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
                                                                        _formatTime(data?.requestDetail.timeEnd),
                                                                        style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.black
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
                                        ],
                                      )
                                  ),
                                  Padding(
                                    padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'หมายเหตุ:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.lightTextColor,
                                          ),
                                        ),
                                        Text(
                                          data?.requestDetail.remark ?? '-',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                          softWrap: true,
                                        ),
                                        SizedBox(height: 10)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Column(
                              spacing: 10,
                              children: [
                                Row(
                                  spacing: 6,
                                  children: [
                                    SvgPicture.asset('assets/images/icon_attach_evidence.svg'),
                                    Text('ไฟล์ที่แนบมา')
                                  ],
                                ),
                                if (data!.requestDetail.evidenceFiles.isNotEmpty)
                                  ...data!.requestDetail.evidenceFiles.map((file) {

                                    bool downloading = false;
                                    MenuController menuController = MenuController();

                                    return Material(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      child: InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () {
                                            FilePreviewPopup(
                                                file: file
                                            ).showPopup(context);
                                          },
                                          splashFactory: NoSplash.splashFactory,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                  child: Row(
                                                    spacing: 6,
                                                    children: [
                                                      SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: SvgPicture.asset(
                                                          file.fileType.toLowerCase() == 'pdf' ? 'assets/images/file.svg' : 'assets/images/photos_upload.svg',
                                                          colorFilter: ColorFilter.mode(Colors.grey.shade800, BlendMode.srcIn),
                                                        ),
                                                      ),
                                                      Expanded(child: Text(file.fileName)),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return downloading ?
                                                    Padding(
                                                      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                                                      child: Center(child: CupertinoActivityIndicator()),
                                                    ) :
                                                    MenuAnchor(
                                                      controller: menuController,
                                                      builder: (context, controller, child) {
                                                        return InkWell(
                                                          overlayColor: WidgetStatePropertyAll(Colors.transparent),
                                                          onTap: () {
                                                            menuController.open();
                                                          },
                                                          child: Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                              child: SvgPicture.asset(
                                                                'assets/images/icon_file_menu.svg',
                                                                colorFilter: ColorFilter.mode(
                                                                  Colors.grey.shade600,
                                                                  BlendMode.srcIn,
                                                                ),
                                                              )
                                                          ),
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
                                                                // 🚩 (2026-08-26) เดิมเป็นปุ่มเดียวชื่อ "ส่งออกไฟล์" ที่ทำสองความหมายปนกัน
                                                                // — บนมือถือมันเปิด share sheet (ส่งต่อ) บนเว็บมันเปิดแท็บใหม่ (ดู)
                                                                // ไม่มีทางไหนเลยที่บันทึกลงเครื่องจริงๆ แยกเป็นสองปุ่มตามที่ผู้ใช้ตั้งใจ
                                                                IconTextButton(
                                                                  icon: 'download.svg',
                                                                  arrow: false,
                                                                  label: 'บันทึกไฟล์',
                                                                  onPressed: () async {
                                                                    menuController.close();
                                                                    Downloader(
                                                                        onDownloadStart: () => setState(() {
                                                                          downloading = true;
                                                                        }),
                                                                        onDownloadSuccess: () => setState(() {
                                                                          downloading = false;
                                                                        })
                                                                    ).saveFile(file);
                                                                  },
                                                                ),
                                                                // เว็บไม่มี share sheet ที่ส่งไฟล์ได้จริง จึงไม่ต้องมีปุ่มนี้
                                                                if (Downloader.canShare)
                                                                  IconTextButton(
                                                                    icon: 'icon_send.svg',
                                                                    arrow: false,
                                                                    label: 'แชร์ไฟล์',
                                                                    onPressed: () async {
                                                                      menuController.close();
                                                                      Downloader(
                                                                          onDownloadStart: () => setState(() {
                                                                            downloading = true;
                                                                          }),
                                                                          onDownloadSuccess: () => setState(() {
                                                                            downloading = false;
                                                                          })
                                                                      ).shareFile(file);
                                                                    },
                                                                  ),
                                                                Padding(
                                                                  padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 5),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        'ขนาด: ${Utils.formatBytes(file.fileSize)}',
                                                                        style: TextStyle(
                                                                            color: Color(0xFF7D7D7D)
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                              )
                                            ],
                                          )
                                      ),
                                    );
                                  })
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    child: SeparatorCard(
                                      children: [
                                        Padding(
                                          padding: EdgeInsetsGeometry.all(20),
                                          child: Text(
                                            'ไม่มีไฟล์แนบ',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF7D7D7D), // สีจาง
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 140)
                              ],
                            ),
                          ],
                        ),
                    )
                  ),
                  if (data?.approveDetail.status == 'pending' && widget.permissionLevel >= 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: SafeArea(child: SeparatorCard(
                              separatorPadding: const EdgeInsetsGeometry.symmetric(horizontal: 15),
                              children: [
                                TextField(
                                  controller: _textEditingController,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    errorStyle: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14
                                    ),
                                    isDense: true,
                                    hintText: 'ระบุเหตุผล...',
                                    hintStyle: const TextStyle(
                                        color: Color(0xFF7D7D7D),
                                        fontSize: 15
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                      horizontal: 15,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(22),
                                      borderSide: BorderSide.none,
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(22),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(22),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 5),
                                  child: Row(
                                    spacing: 15,
                                    children: [
                                      Expanded(
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              minimumSize: const WidgetStatePropertyAll(Size(0, 0)),
                                              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                                              backgroundColor: const WidgetStatePropertyAll(Color(0xFFFFD9D9)),
                                              shape: WidgetStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(50)
                                                  )
                                              ),
                                              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                                              overlayColor: WidgetStateProperty<Color?>.fromMap(<WidgetState, Color?>{
                                                WidgetState.pressed: Colors.white.withValues(alpha: 0.4),
                                              }),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 8),
                                              child: Stack(
                                                children: [
                                                  const Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'ไม่อนุมัติ',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(0xFFFF4040),
                                                            fontWeight: FontWeight.w600
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/images/icon_cancel.svg',
                                                        width: 20,
                                                        height: 20,
                                                        colorFilter: const ColorFilter.mode(Color(0xFFFF4040), BlendMode.srcIn),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (setting!.approveNeedSignature) {
                                                final navigator = Navigator.of(context, rootNavigator: true);
                                                final provider = PopupProvider.of(context);
                                                final oldConfig = provider.config;

                                                provider.setConfig(PopupConfig(
                                                  title: 'ลายเซ็น',
                                                  buttonLabel: 'ไม่อนุมัติ',
                                                  maxHeight: 700,
                                                  scroll: false,
                                                ));

                                                await provider.push(context, ServiceSignaturePage(
                                                  required: true,
                                                  infoWidget: Row(
                                                    spacing: 5,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/images/iicon.svg',
                                                        width: 15,
                                                        height: 15,
                                                      ),
                                                      const Expanded(
                                                          child: Text.rich(
                                                              TextSpan( 
                                                                text: 'โปรดทราบว่า การเซ็นลายเซ็นดิจิทัลนี้ใช้สำหรับ',
                                                                children: [
                                                                  TextSpan(
                                                                    text: 'ยืนยันการปฏิเสธคำขอลงเวลาเข้า-ออกในครั้งนี้เท่านั้น',
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      decoration: TextDecoration.underline,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' และจะไม่ถูกนำไปใช้เพื่อวัตถุประสงค์อื่น',
                                                                  ),
                                                                ],
                                                              )
                                                          )
                                                      )
                                                    ],
                                                  ),
                                                  request: (pngByte) => AttendanceApprovalService().approval(widget.id, 'rejected', _textEditingController.text, pngByte),
                                                  onSuccessResponse: (pngBytes, jsonData) {
                                                    navigator.pop();
                                                    widget.onRejected();

                                                    NotificationService().sendApprovalResponseNotification('ATTENDANCE_REQUEST', widget.id, 'REJECTED');
                                                  },
                                                ));

                                                provider.setConfig(oldConfig);
                                              } else {
                                                FloatingPopup(
                                                    title: 'ปฏิเสธคำขอ',
                                                    description: 'คุณยืนยันที่จะปฏิเสธคำขอหมายเลข: ${widget.id} หรือไม่?',
                                                    buttons: (setError, context1) {
                                                      return [
                                                        FloatingPopupButton(
                                                          onPressed: () {
                                                            Navigator.of(context1).pop();
                                                          },
                                                          text: 'ยกเลิก',
                                                          foregroundColor: Colors.white,
                                                          backgroundColor: AppColors.primaryColor,
                                                        ),
                                                        FloatingServicePopupButton(
                                                          text: 'ยืนยัน',
                                                          foregroundColor: Colors.red,
                                                          request: () => AttendanceApprovalService().approval(widget.id, 'rejected', _textEditingController.text, null),
                                                          setError: setError,
                                                          onSuccess: () async {
                                                            Navigator.of(context1).pop();
                                                            await Future.delayed(const Duration(milliseconds: 200));
                                                            if (!context.mounted) return;
                                                            Navigator.of(context, rootNavigator: true).pop();
                                                            widget.onRejected();

                                                            NotificationService().sendApprovalResponseNotification('ATTENDANCE_REQUEST', widget.id, 'REJECTED');
                                                          },
                                                        )
                                                      ];
                                                    }
                                                ).showPopup(context);
                                              }
                                            },
                                          )
                                      ),
                                      Expanded(
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              minimumSize: const WidgetStatePropertyAll(Size(0, 0)),
                                              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                                              backgroundColor: const WidgetStatePropertyAll(Color(0xFFCDF2E4)),
                                              shape: WidgetStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(50)
                                                  )
                                              ),
                                              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                                              overlayColor: WidgetStateProperty<Color?>.fromMap(<WidgetState, Color?>{
                                                WidgetState.pressed: Colors.white.withValues(alpha: 0.4),
                                              }),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 8),
                                              child: Stack(
                                                children: [
                                                  const Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'อนุมัติ',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(0xFF03BC78),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/images/icon_cancel.svg',
                                                        width: 20,
                                                        height: 20,
                                                        colorFilter: const ColorFilter.mode(Color(0xFF03BC78), BlendMode.srcIn),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (setting!.approveNeedSignature) {
                                                final navigator = Navigator.of(context, rootNavigator: true);
                                                final provider = PopupProvider.of(context);
                                                final oldConfig = provider.config;

                                                provider.setConfig(PopupConfig(
                                                  title: 'ลายเซ็น',
                                                  buttonLabel: 'อนุมัติ',
                                                  maxHeight: 700,
                                                  scroll: false,
                                                ));

                                                await provider.push(context, ServiceSignaturePage(
                                                  required: true,
                                                  infoWidget: Row(
                                                    spacing: 5,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/images/iicon.svg',
                                                        width: 15,
                                                        height: 15,
                                                      ),
                                                      const Expanded(
                                                          child: Text.rich(
                                                              TextSpan(
                                                                text: 'โปรดทราบว่า การเซ็นลายเซ็นดิจิทัลนี้ใช้สำหรับ',
                                                                children: [
                                                                  TextSpan(
                                                                    text: 'ยืนยันการอนุมัติคำขอลงเวลาเข้า-ออกในครั้งนี้เท่านั้น',
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      decoration: TextDecoration.underline,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' และจะไม่ถูกนำไปใช้เพื่อวัตถุประสงค์อื่น',
                                                                  ),
                                                                ],
                                                              )
                                                          )
                                                      )
                                                    ],
                                                  ),
                                                  request: (pngByte) => AttendanceApprovalService().approval(widget.id, 'approved', _textEditingController.text, pngByte),
                                                  onSuccessResponse: (pngBytes, jsonData) {
                                                    navigator.pop();
                                                    widget.onApproved();

                                                    NotificationService().sendApprovalResponseNotification('ATTENDANCE_REQUEST', widget.id, 'APPROVED');
                                                  },
                                                ));

                                                provider.setConfig(oldConfig);
                                              } else {
                                                FloatingPopup(
                                                    title: 'อนุมัติคำขอ',
                                                    description: 'คุณยืนยันที่จะอนุมัติคำขอหมายเลข: ${widget.id} หรือไม่?',
                                                    buttons: (setError, context1) {
                                                      return [
                                                        FloatingPopupButton(
                                                          onPressed: () {
                                                            Navigator.of(context1).pop();
                                                          },
                                                          text: 'ยกเลิก',
                                                          foregroundColor: Colors.white,
                                                          backgroundColor: AppColors.primaryColor,
                                                        ),
                                                        FloatingServicePopupButton(
                                                          text: 'ยืนยัน',
                                                          foregroundColor: Colors.red,
                                                          request: () => AttendanceApprovalService().approval(widget.id, 'approved', _textEditingController.text, null),
                                                          setError: setError,
                                                          onSuccess: () async {
                                                            Navigator.of(context1).pop();
                                                            await Future.delayed(const Duration(milliseconds: 200));
                                                            if (!context.mounted) return;
                                                            Navigator.of(context, rootNavigator: true).pop();
                                                            widget.onApproved();

                                                            NotificationService().sendApprovalResponseNotification('ATTENDANCE_REQUEST', widget.id, 'APPROVED');
                                                          },
                                                        )
                                                      ];
                                                    }
                                                ).showPopup(context);
                                              }
                                            },
                                          )
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ))
                        ),
                      ],
                      ),
                    )
                ],
              );
            }
        )
    );
  }
}