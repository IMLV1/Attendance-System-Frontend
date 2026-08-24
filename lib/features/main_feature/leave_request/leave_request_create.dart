import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/services/system_config/budget_year/config_budget_year_service.dart';
import 'package:attendance_system/features/main_feature/leave_request/date_select.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_type.dart';
import 'package:attendance_system/features/main_feature/leave_request/select_leave_type.dart';
import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:attendance_system/services/leave/leave_service.dart';
import 'package:attendance_system/services/notification/notification_service.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/service_signature_popup.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../shared/widgets/utils/separator_card.dart';
import '../../../shared/widgets/utils/text_button.dart' as utils;

class LeaveRequestCreate extends StatefulWidget {
  const LeaveRequestCreate({super.key});

  @override
  State<LeaveRequestCreate> createState() => _LeaveRequestPage();
}

class _LeaveRequestPage extends State<LeaveRequestCreate> {

  int limitFileSize = 52428800;

  LeaveType? leaveType;
  LeaveSetting? setting;
  LeaveDate? leaveDate;

  LeaveDate? _selectedDate;

  // 🚩 เพิ่ม (2026-08-13): ขอบเขตปีงบประมาณปัจจุบัน ใช้จำกัดปฏิทินเลือกวันลา
  // (ยื่นลาได้เฉพาะในปีงบปัจจุบัน — backend บังคับซ้ำอีกชั้น)
  DateTime? _budgetStart;
  DateTime? _budgetEnd;

  LeaveInfoModel? leaveStatsInfo;

  List<PlatformFile> allFiles = [];

  final MenuController _menuController = MenuController();
  final TextEditingController _textEditingController = TextEditingController();

  bool submitted = false;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    _loadBudgetPeriod();
  }

  // ดึงขอบเขตปีงบปัจจุบันมาจำกัดปฏิทิน — ถ้าล้มเหลวปล่อยเป็น null (ไม่จำกัดฝั่ง UI)
  // แล้วให้ backend เป็นด่านบล็อกแทน จะได้ไม่ทำให้หน้าใช้ไม่ได้ทั้งหน้า
  Future<void> _loadBudgetPeriod() async {
    try {
      final res = await ConfigBudgetYearService().getCurrentPeriod();
      final start = res.data?['date-start'];
      final end = res.data?['date-end'];
      if (start != null && end != null && mounted) {
        setState(() {
          _budgetStart = DateTime.parse(start);
          _budgetEnd = DateTime.parse(end);
        });
      }
    } catch (_) {
      // เงียบไว้ — backend ยังบล็อกให้อยู่ดี
    }
  }

  // 🚩 แก้ (2026-08-13): เดิมคำนวณ "จำนวนวันลา" เองจากผลต่างวันปฏิทินดิบ ซึ่งไม่ตัด
  // เสาร์-อาทิตย์/วันหยุด → ไม่ตรงกับที่ backend หักจริงตอนอนุมัติ (เช่น 3–14 ส.ค. 2026
  // นับได้ 12 แต่หักจริง 9) ทำให้คำเตือน "จะเกินสิทธิ์กี่วัน" เพี้ยน
  // ตอนนี้ถามจาก backend (ใช้ CalculateLeaveDays ตัวเดียวกับตอนอนุมัติ) แทน
  double? _calculatedLeaveDays;

  Future<void> _recalculateLeaveDays() async {
    final d = leaveDate;
    if (d?.fromDate == null || d?.toDate == null) {
      setState(() => _calculatedLeaveDays = null);
      return;
    }
    try {
      final res = await LeaveRequestService().calculateLeaveDays(
        d!.fromDate!,
        d.toDate!,
        fromDateMorning: d.fromDateMorning,
        toDateMorning: d.toDateMorning,
      );
      final days = (res.data?['days'] as num?)?.toDouble();
      if (mounted) setState(() => _calculatedLeaveDays = days);
    } catch (_) {
      // ถามไม่ได้ ใช้วันปฏิทินดิบไปก่อน (จะได้ไม่บล็อกการใช้งาน) — backend ยังเป็นตัวตัดสิน
      if (mounted) setState(() => _calculatedLeaveDays = null);
    }
  }

  double getLeaveDays() {
    if (_calculatedLeaveDays != null) return _calculatedLeaveDays!;

    // fallback: วันปฏิทินดิบ (ใช้เฉพาะตอนถาม backend ไม่ได้)
    double leaveDays = leaveDate!.toDate!.difference(leaveDate!.fromDate!).inDays + 1;
    double period = (leaveDate!.fromDateMorning ? 0 : -0.5) + (leaveDate!.toDateMorning ? -0.5 : 0);
    return leaveDays + period;
  }

  // หักคำขอที่ยังรออนุมัติออกด้วย ไม่งั้นจะเห็นสิทธิ์คงเหลือเกินจริง
  double getRemainLeaveDays() {
    return leaveStatsInfo?.remain ?? 0;
  }

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
        header: Header.subHeader(
            context,
            title: 'สร้างคำขอ',
        ),
        content: SafeArea(
            child: Container(
                color: AppColors.backgroundColor,
                alignment: Alignment.topCenter,
                child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: Stack(
                      children: [
                        Column(
                            children: [
                              Expanded(
                                  child: SingleChildScrollView(
                                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                              ServiceUpdater(
                                                request: () => LeaveRequestService().getLeaveInfo(leaveType!),
                                                onSuccessResponse: (jsonData) {
                                                  setState(() {
                                                    leaveStatsInfo = LeaveInfoModel.fromJson(jsonData);
                                                  });
                                                },
                                                builder: (trigger, state, errorMessage) {
                                                  return Container(
                                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10) ,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFEAEAEA),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      spacing: 13,
                                                      children: [
                                                        Column(
                                                          spacing: 6,
                                                          children: [
                                                            SeparatorCard(
                                                              children: [
                                                                utils.TextButton(
                                                                  label: leaveType?.display ?? 'เลือกประเภทการลา',
                                                                  color: leaveType == null ? Color(0xFF7D7D7D) : Colors.black,
                                                                  onPressed: () async {
                                                                    /// TODO: Select Leave Request
                                                                    final leaveType = await Navigator.of(context).push<LeaveType?>(
                                                                      MaterialPageRoute(
                                                                        builder: (_) => const SelectLeaveType(),
                                                                      ),
                                                                    );
                                                                    if (leaveType != null) {
                                                                      setState(() {
                                                                        this.leaveType = leaveType;
                                                                        setting = leaveType.getSetting(context);

                                                                        leaveDate = null;
                                                                        _calculatedLeaveDays = null;
                                                                        _textEditingController.text = '';
                                                                        allFiles.clear();

                                                                        trigger();
                                                                      });
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            if (leaveStatsInfo != null) Row(
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

                                                                      RichText(
                                                                        text: TextSpan(
                                                                          style: const TextStyle(
                                                                            fontSize: 12,
                                                                            color: Colors.black,
                                                                          ),
                                                                          children: [
                                                                            TextSpan(
                                                                              // 🚩 หักคำขอที่ยังรออนุมัติออกด้วย (leaveStatsInfo.remain) เดิมใช้แค่ max-used
                                                                              // ซึ่ง used เพิ่มตอนอนุมัติเท่านั้น → ยื่นค้างไว้กี่ใบก็ยังเห็นเหลือเต็มโควตา
                                                                              text: (leaveStatsInfo!.remain <= 0)
                                                                                  ? 'คุณได้ใช้สิทธิ์การ${leaveType!.display}ครบตามจำนวนที่กำหนดแล้ว'
                                                                                  : 'คุณใช้สิทธิ์${leaveType!.display}ไปแล้ว ${Utils.formatDays(leaveStatsInfo!.used)} วัน'
                                                                                      '${leaveStatsInfo!.pending > 0 ? ' และมีคำขอรออนุมัติอีก ${Utils.formatDays(leaveStatsInfo!.pending)} วัน' : ''}'
                                                                                      ' ยังเหลือสิทธิ์ลา${leaveType!.display}อีก ${Utils.formatDays(leaveStatsInfo!.remain)} วัน ',
                                                                              style: TextStyle(
                                                                                color: (leaveStatsInfo!.remain <= 0) ? Colors.red : Colors.black
                                                                              )
                                                                            ),
                                                                            TextSpan(
                                                                              text: 'ดูข้อมูลเพิ่มเติม',
                                                                              style: const TextStyle(
                                                                                color: Colors.blue,
                                                                                decoration: TextDecoration.underline,
                                                                              ),
                                                                              recognizer: TapGestureRecognizer()
                                                                                ..onTap = () {
                                                                                  context.goNamed(RouteNames.statistic);
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
                                                        if (leaveType != null) Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            ElevatedButton(

                                                                onPressed: () {
                                                                  PushPopup(
                                                                      title: 'เลือกวันที่',
                                                                      fit: FlexFit.tight,
                                                                      maxHeight: 700,
                                                                      buttonLabel: 'บันทึก',
                                                                      builder: (context) {

                                                                        _selectedDate = leaveDate;

                                                                        return DateSelect(
                                                                          dateData: leaveDate,
                                                                          allowRetroactive: setting!.allowRetroactive,
                                                                          budgetStart: _budgetStart,
                                                                          budgetEnd: _budgetEnd,
                                                                          onChanged: (LeaveDate date) {
                                                                            _selectedDate = date;
                                                                          }
                                                                        );
                                                                      },
                                                                      buttonAction: (context) {

                                                                        Navigator.of(context).pop();

                                                                        setState(() {
                                                                          leaveDate = _selectedDate;
                                                                        });
                                                                        // ถามจำนวนวันลาจริงจาก backend (ตัดเสาร์-อาทิตย์/วันหยุด)
                                                                        _recalculateLeaveDays();
                                                                      }
                                                                  ).showPopup(context);
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  shadowColor: Colors.transparent,
                                                                  overlayColor: Colors.transparent,
                                                                  elevation: 0,
                                                                  minimumSize: Size(0, 0),
                                                                  padding: EdgeInsets.zero,
                                                                ),
                                                                child: Container(
                                                                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 15),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(15),
                                                                      border: (submitted && leaveDate == null)
                                                                          ? Border.all(
                                                                        color: Colors.red,
                                                                        width: 1.5,
                                                                      ) : null,
                                                                    ),
                                                                    child: Row(
                                                                      spacing: 10,
                                                                      children: [
                                                                        Expanded(
                                                                            child: Row(
                                                                              spacing: 10,
                                                                              children: [
                                                                                SvgPicture.asset('assets/images/calendar_in.svg'),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'จากวันที่',
                                                                                      style: TextStyle(
                                                                                          color: Color(0xFF626262)
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      (leaveDate?.fromDate != null) ? '${DateFormat.MMMd('th_TH').format(leaveDate!.fromDate!)} ${num.parse(DateFormat.y('th_TH').format(leaveDate!.fromDate!)) + 543} ${leaveDate!.fromDateMorning ? 'เช้า' : 'เย็น'}' : '---',
                                                                                      style: TextStyle(
                                                                                          fontSize: 14
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            )
                                                                        ),
                                                                        Container(width: 1.5, height: 40, color: Color(0xFFB1B1B1)),
                                                                        Expanded(
                                                                            child: Row(
                                                                              spacing: 10,
                                                                              children: [
                                                                                SvgPicture.asset('assets/images/calendar_out.svg'),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'ถึงวันที่',
                                                                                      style: TextStyle(
                                                                                          color: Color(0xFF626262)
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      (leaveDate?.toDate != null) ? '${DateFormat.MMMd('th_TH').format(leaveDate!.toDate!)} ${num.parse(DateFormat.y('th_TH').format(leaveDate!.toDate!)) + 543} ${leaveDate!.toDateMorning ? 'เช้า' : 'เย็น'}' : '---',
                                                                                      style: TextStyle(
                                                                                          fontSize: 14
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            )
                                                                        )
                                                                      ],
                                                                    )
                                                                )
                                                            ),
                                                            AnimatedSwitcher(
                                                              duration: Duration(milliseconds: 200),
                                                              transitionBuilder: (child, animation) {
                                                                return SlideTransition(
                                                                  position: Tween<Offset>(
                                                                    begin: Offset(0, -0.2),
                                                                    end: Offset.zero,
                                                                  ).animate(animation),
                                                                  child: FadeTransition(
                                                                    opacity: animation,
                                                                    child: child,
                                                                  ),
                                                                );
                                                              },
                                                              child: (submitted && leaveDate == null)
                                                                  ? Padding(
                                                                padding: EdgeInsets.only(left: 13, top: 8),
                                                                child: Text(
                                                                  'กรุณาระบุวันที่และเวลา',
                                                                  style: TextStyle(
                                                                    color: Colors.red,
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                              ) : SizedBox(),
                                                            ),

                                                            // 🚩 (2026-08-22) สรุปว่าคำขอนี้จะใช้โควตากี่วัน
                                                            // ตัวเลขมาจาก backend (ตัดเสาร์-อาทิตย์/วันหยุดแล้ว) ผู้ใช้จะได้
                                                            // เห็นก่อนกดส่งว่าโดนหักจริงเท่าไร ไม่ใช่เดาจากจำนวนวันปฏิทิน
                                                            AnimatedSwitcher(
                                                              duration: const Duration(milliseconds: 200),
                                                              child: (leaveDate != null && _calculatedLeaveDays != null)
                                                                  ? Padding(
                                                                      padding: const EdgeInsets.only(left: 13, right: 13, top: 8),
                                                                      child: Row(
                                                                        spacing: 6,
                                                                        children: [
                                                                          SvgPicture.asset(
                                                                            'assets/images/iicon.svg',
                                                                            width: 14,
                                                                            height: 14,
                                                                          ),
                                                                          Expanded(
                                                                            child: Text.rich(
                                                                              TextSpan(
                                                                                text: 'คำขอนี้จะใช้สิทธิ์',
                                                                                style: const TextStyle(fontSize: 13, color: Colors.black),
                                                                                children: [
                                                                                  TextSpan(
                                                                                    text: ' ${Utils.formatDays(_calculatedLeaveDays!)} วัน',
                                                                                    style: const TextStyle(
                                                                                      fontSize: 13,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                  if (_calculatedLeaveDays! == 0)
                                                                                    const TextSpan(text: ' (ช่วงที่เลือกเป็นวันหยุดทั้งหมด)')
                                                                                  else
                                                                                    TextSpan(
                                                                                      text: ' จากที่เหลือ ${Utils.formatDays(getRemainLeaveDays())} วัน',
                                                                                    ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : const SizedBox(),
                                                            )
                                                          ],
                                                        ),
                                                        if (leaveType != null && setting!.specifyRemark)
                                                          TextField(
                                                            controller: _textEditingController,
                                                            maxLines: 1,
                                                            decoration: InputDecoration(
                                                              errorText: (submitted && setting!.requiredRemark == true && _textEditingController.text.isEmpty) ? 'กรุณาระบุหมายเหตุ' : null,
                                                              errorStyle: TextStyle(
                                                                  color: Colors.red,
                                                                  fontSize: 14
                                                              ),
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
                                                              errorBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(22),
                                                                borderSide: BorderSide(
                                                                  color: Colors.red,
                                                                  width: 1.5,
                                                                ),
                                                              ),
                                                              focusedErrorBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(22),
                                                                borderSide: BorderSide(
                                                                  color: Colors.red,
                                                                  width: 1.5,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        if (leaveType != null && setting!.evidenceFile) Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(25),
                                                                border: (submitted &&
                                                                    setting?.requiredEvidenceFile == true &&
                                                                    (allFiles.isEmpty ||
                                                                      allFiles.fold(0, (sum, file) => sum + file.size) > limitFileSize)
                                                                  )
                                                                    ? Border.all(
                                                                  color: Colors.red,
                                                                  width: 1.5,
                                                                ) : null,
                                                              ),
                                                              child: SeparatorCard(
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

                                                                                    final extension = p.extension(image.name);
                                                                                    final bytes = await image.readAsBytes();

                                                                                    final file = PlatformFile(
                                                                                      name: 'IMG_${Utils.generateRandomNumber(5)}$extension',
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

                                                                                    final extension = p.extension(image.name);
                                                                                    final bytes = await image.readAsBytes();

                                                                                    final file = PlatformFile(
                                                                                      name: 'IMG_${Utils.generateRandomNumber(5)}$extension',
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
                                                                                            Text('ขนาด ${Utils.formatBytes(file.size)}',
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
                                                              ),
                                                            ),

                                                            AnimatedSwitcher(
                                                              duration: Duration(milliseconds: 200),
                                                              transitionBuilder: (child, animation) {
                                                                return SlideTransition(
                                                                  position: Tween<Offset>(
                                                                    begin: Offset(0, -0.2),
                                                                    end: Offset.zero,
                                                                  ).animate(animation),
                                                                  child: FadeTransition(
                                                                    opacity: animation,
                                                                    child: child,
                                                                  ),
                                                                );
                                                              },
                                                              child: (submitted && setting!.requiredEvidenceFile &&
                                                                  (allFiles.isEmpty || allFiles.fold(0, (sum, file) => sum + file.size) > limitFileSize))
                                                                  ? Padding(
                                                                padding: EdgeInsets.only(left: 13, top: 8),
                                                                child: Text(
                                                                  (allFiles.fold(0, (sum, file) => sum + file.size) > limitFileSize) ? 'ขนาดไฟล์รวมเกิน ${Utils.formatBytes(limitFileSize)}' : 'กรุณาแนบไฟล์',
                                                                  style: TextStyle(
                                                                    color: Colors.red,
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                              ) : SizedBox(),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }
                                              ),
                                              SizedBox(height: 20)
                                            ],
                                          )
                                        ],
                                      )
                                  )
                              )
                            ]
                        ),

                        ServiceUpdater(
                          request: () => LeaveRequestService().create(leaveType!, leaveDate!, _textEditingController.text, allFiles, null),
                          onSuccessResponse: (jsonData) {
                            final String? requestID = jsonData['request-id'];
                            // Explicitly define the return type in the brackets <>
                            context.pop<(String?, String?, DateTime?)?>(
                              (requestID, leaveType?.name, leaveDate?.fromDate),
                            );

                            if (requestID != null) {
                              NotificationService().sendRequestNotification('APPROVER_LEAVE', requestID);
                            }
                          },
                          builder: (trigger, state, errorMessage) {
                            return Padding(
                                padding: EdgeInsetsGeometry.symmetric(vertical: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: 42,
                                          child: ElevatedButton.icon(
                                            onPressed: (leaveType != null && state != .loading) ? () {

                                              setState(() {
                                                submitted = true;
                                              });

                                              if (leaveDate == null) return;

                                              if (setting!.requiredRemark && _textEditingController.text.isEmpty) return;
                                              if (setting!.requiredEvidenceFile && allFiles.isEmpty) return;

                                              if (allFiles.fold(0, (sum, file) => sum + file.size) > limitFileSize) return;

                                              if (getLeaveDays() > getRemainLeaveDays() && !confirmed) {
                                                confirmed = true;
                                                return;
                                              }

                                              if (setting!.requestNeedSignature) {
                                                ServiceSignaturePopup(
                                                  title: 'ลายเซ็น',
                                                  buttonLabel: 'ส่ง',
                                                  fit: FlexFit.tight,
                                                  maxHeight: 700,
                                                  onSuccessResponse: (pngBytes, jsonData) {
                                                    final String? requestID = jsonData['request-id'];
                                                    context.pop<(String?, String?, DateTime?)?>(
                                                      (requestID, leaveType?.name, leaveDate?.fromDate),
                                                    );

                                                    if (requestID != null) {
                                                      NotificationService().sendRequestNotification('APPROVER_LEAVE', requestID);
                                                    }
                                                  },
                                                  infoWidget: Row(
                                                    spacing: 5,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/images/iicon.svg',
                                                        width: 15,
                                                        height: 15,
                                                      ),
                                                      Expanded(
                                                          child: Text.rich(
                                                              TextSpan(
                                                                text: 'โปรดทราบว่า การเซ็นลายเซ็นดิจิทัลนี้ใช้สำหรับ',
                                                                children: [
                                                                  TextSpan(
                                                                    text: 'ยืนยันการขอลางานในครั้งนี้เท่านั้น',
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
                                                  required: true,
                                                  request: (pngByte) => LeaveRequestService().create(leaveType!, leaveDate!, _textEditingController.text, allFiles, pngByte!),
                                                ).showPopup(context);
                                              } else {
                                                trigger();
                                              }
                                            } : null,
                                            icon: SvgPicture.asset(
                                              'assets/images/icon_send.svg',
                                              height: 18,
                                              width: 18,
                                              colorFilter: ColorFilter.mode(
                                                Colors.white,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            label: Row(
                                              spacing: 6,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'ส่ง',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                if (state == .loading) CupertinoActivityIndicator(color: Colors.white),
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
                                        if (state == ServiceUpdatorState.error)
                                          const Text(
                                            'เกิดข้อผิดพลาด กรุณาลองอีกครั้ง...',
                                            style: TextStyle(color: Colors.red),
                                          )
                                        else if (confirmed && getLeaveDays() > getRemainLeaveDays())
                                          Row(
                                            spacing: 6,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/icon_warning.svg',
                                                colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
                                              ),
                                              Expanded(
                                                child: Wrap(
                                                  children: [
                                                    RichText(
                                                        text: TextSpan(
                                                            // 🚩 เดิม hardcode 'ลาป่วย' ทุกประเภท + โชว์เลขดิบ (เช่น 2.0)
                                                            text: 'คุณได้ใช้สิทธิ์การ${leaveType?.display ?? 'ลา'}ครบตามจำนวนที่กำหนดแล้ว หากคำขอนี้ได้รับการอนุมัติจำนวนวันลาของคุณจะเกินสิทธิ์ทั้งหมด ${Utils.formatDays(getLeaveDays() - getRemainLeaveDays())} วัน ซึ่งอาจส่งผลต่อการคำนวณตัวชี้วัดผลการปฏิบัติงาน ',
                                                            style: TextStyle(
                                                                color: Colors.red
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                  text: 'กรุณากดปุ่มอีกครั้ง',
                                                                  style: TextStyle(
                                                                    color: Colors.red,
                                                                    fontWeight: FontWeight.bold,
                                                                  )
                                                              ),
                                                              TextSpan(
                                                                  text: ' เพื่อดำเนินการต่อ',
                                                                  style: TextStyle(
                                                                    color: Colors.red,
                                                                  )
                                                              )
                                                            ]
                                                        )
                                                    )
                                                  ],
                                                )
                                              )
                                            ],
                                          )
                                      ],
                                    )
                                  ],
                                )
                            );
                          }
                        )
                      ],
                    )
                )
            )
        )
    );
  }
}