import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/services/approval/leave/leave_service.dart';
import 'package:attendance_system/services/notification/notification_service.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../services/leave/leave_model.dart';
import '../../../../services/system_config/leave/config_leave_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/utils/animation/animated_widget.dart';
import '../../../../shared/widgets/utils/app_button.dart';
import '../../../../shared/widgets/utils/downloader.dart';
import '../../../../shared/widgets/utils/icon_text_button.dart';
import '../../../../shared/widgets/utils/popup/file_preview_popup.dart';
import '../../../../shared/widgets/utils/popup/floating_popup.dart';
import '../../../../shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import '../../../../shared/widgets/utils/popup/multi_page/service_signature_page.dart';
import '../../../../shared/widgets/utils/separator_card.dart';
import '../../../../shared/widgets/utils/services/service_loader.dart';
import '../../../../shared/widgets/utils/services/service_updater.dart';
import '../../../main_feature/leave_request/leave_request_detail.dart';
import '../../../main_feature/leave_request/leave_type.dart';

class LeaveApprovalDetailPopup extends StatefulWidget {
  final String requestID;
  final void Function() onApproved;
  final void Function() onRejected;
  const LeaveApprovalDetailPopup({
    super.key,
    required this.requestID,
    required this.onApproved,
    required this.onRejected,
  });

  @override
  State<LeaveApprovalDetailPopup> createState() {
    return _LeaveApprovalDetailPopup();
  }
}

class _LeaveApprovalDetailPopup extends State<LeaveApprovalDetailPopup> {
  LeaveRequestDetailModel? requestDetail;
  bool onSelect = false;

  LeaveSetting? setting;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final auth = context.read<AuthState>();

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: ServiceLoader(
        request: () => LeaveApprovalService().getRequestDetail(widget.requestID), // mockData(),
        onSuccess: (val) {
          setState(() {
            requestDetail = LeaveRequestDetailModel.fromJson(val['data']);
            setting = requestDetail!.requestDetail.leaveType.getSetting(context);
          });
        },
        builder: () {
          final status = requestDetail?.approveDetail.status ?? .pending;

          return Column(
            mainAxisSize: MainAxisSize.min, // ✅ แก้ไขที่ 3: จำกัดความสูง Column ภายใน
            children: [
              Expanded( // ✅ แก้ไขที่ 4: ใช้ Flexible ชั้นเดียว แทนการซ้อน Expanded -> Column -> Expanded
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
                                icon: status.icon,
                                title: switch (status) {
                                      .approved => 'อนุมัติแล้ว',
                                      .rejected => 'ไม่อนุมัติ',
                                      .pending => 'รออนุมัติ',
                                      .overdue => 'เลยกำหนดเวลา',
                                      .canceled => 'ยกเลิก'
                                },
                                iconColor: status.color,
                                weightTitle: FontWeight.w500,
                                subTitle: switch (status) {
                                      .overdue => 'คำขอนี้เลยกำหนดเวลาอนุมัติแล้ว',
                                      .canceled => 'คำขอนี้ถูกยกเลิกแล้ว',
                                      .pending => 'ตำแหน่งที่รับผิดชอบการอนุมัติ: ${requestDetail?.approveDetail.approveRole ?? '-'}',
                                  _ => 'เนื่องจาก: ${requestDetail?.approveDetail.reason ?? '-'}',
                                },
                                arrow: false,
                                timeStamp: requestDetail?.approveDetail.approveDate != null
                                    ? formatDateTime(requestDetail!.approveDetail.approveDate!)
                                    : null,
                                onPressed: () {
                                  setState(() {
                                    onSelect = !onSelect;
                                  });
                                },
                              ),
                              AnimatedSizeWidget(
                                enable: onSelect && !(status == .pending || status == .overdue || status == .canceled),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 6,
                                  children: [
                                    const Padding(
                                        padding: EdgeInsetsGeometry.only(right: 15, left: 60),
                                        child: Divider(height: 0)
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(left: 60, right: 15),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'ผู้อนุมัติ:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.lightTextColor,
                                              ),
                                            ),
                                            Text(
                                              requestDetail?.approveDetail.approver ?? '-',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              softWrap: true,
                                            ),
                                            const SizedBox(height: 10)
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
                            color: const Color(0xFFEAEAEA)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppButton(
                              icon: requestDetail?.requestDetail.leaveType.icon ?? 'leave.svg',
                              title: requestDetail?.requestDetail.leaveType.display ?? '---',
                              bg: Colors.white,
                              weightTitle: FontWeight.w500,
                              subTitle: 'หมายเลขตำขอ ${widget.requestID}',
                              arrow: false,
                              onPressed: null,
                            ),
                            Container(
                                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFEAEAEA),
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
                                                    padding: const EdgeInsets.symmetric(
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
                                                            colorFilter: const ColorFilter.mode(Color(0xFF5F5F5F), BlendMode.srcIn),
                                                          ),
                                                        ),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                                'จากวันที่',
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Color(0xFF626262)
                                                                )
                                                            ),
                                                            Text(
                                                                '${_formatDate(requestDetail!.requestDetail.dateFrom)} ${(requestDetail!.requestDetail.fromDateMorning) ? 'เช้า' : 'เย็น'}',
                                                                style: const TextStyle(
                                                                    fontSize: 13,
                                                                    color: Colors.black
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
                                                  margin: const EdgeInsetsGeometry.symmetric(
                                                      horizontal: 3
                                                  )
                                              ),
                                              Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
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
                                                            colorFilter: const ColorFilter.mode(
                                                                Color(0xFF5F5F5F),
                                                                BlendMode.srcIn
                                                            ),
                                                          ),
                                                        ),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                                'ถึงวันที่',
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Color(0xFF626262)
                                                                )
                                                            ),
                                                            Text(
                                                                '${_formatDate(requestDetail!.requestDetail.dateTo)} ${(requestDetail!.requestDetail.toDateMorning) ? 'เช้า' : 'เย็น'}',
                                                                style: const TextStyle(
                                                                    fontSize: 13,
                                                                    color: Colors.black
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
                                      ],
                                    ),
                                  ],
                                )
                            ),
                            Padding(
                              padding: const EdgeInsetsGeometry.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'หมายเหตุ:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.lightTextColor,
                                    ),
                                  ),
                                  Text(
                                    requestDetail?.requestDetail.remark ?? '-',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                    softWrap: true,
                                  ),
                                  const SizedBox(height: 10)
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
                              const Text('ไฟล์ที่แนบมา')
                            ],
                          ),
                          if (requestDetail!.requestDetail.evidenceFiles.isNotEmpty)
                            ...requestDetail!.requestDetail.evidenceFiles.map((file) {
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
                                      FilePreviewPopup(file: file).showPopup(context);
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
                                              const Padding(
                                                padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                                                child: Center(child: CupertinoActivityIndicator()),
                                              ) :
                                              MenuAnchor(
                                                controller: menuController,
                                                useRootOverlay: true,
                                                builder: (context, controller, child) {
                                                  return InkWell(
                                                    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                                                    onTap: () {
                                                      menuController.open();
                                                    },
                                                    child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                                                          IconTextButton(
                                                            icon: 'download.svg',
                                                            arrow: false,
                                                            label: 'ส่งออกไฟล์',
                                                            onPressed: () async {
                                                              menuController.close();
                                                              Downloader(
                                                                  onDownloadStart: () => setState(() {
                                                                    downloading = true;
                                                                  }),
                                                                  onDownloadSuccess: () => setState(() {
                                                                    downloading = false;
                                                                  })
                                                              ).downloadFile(file);
                                                            },
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 5),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  'ขนาด: ${Utils.formatBytes(file.fileSize)}',
                                                                  style: const TextStyle(
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
                ),
              ),

              if (status == .pending && (auth.user?.roleType ?? []).any((r) => r == 'admin' || r == 'approver'))
                Column(
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
                                                                text: 'ยืนยันการปฏิเสธคำขอลางานในครั้งนี้เท่านั้น',
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
                                              request: (pngByte) => LeaveApprovalService().approval(widget.requestID, ApproveStatus.rejected.state, _textEditingController.text, pngByte),
                                              onSuccessResponse: (pngBytes, jsonData) {
                                                navigator.pop();
                                                widget.onRejected();

                                                NotificationService().sendApprovalResponseNotification('LEAVE_REQUEST', widget.requestID, 'REJECTED');
                                              },
                                            ));

                                            provider.setConfig(oldConfig);
                                          } else {
                                            FloatingPopup(
                                                title: 'ปฏิเสธคำขอ',
                                                description: 'คุณยืนยันที่จะปฏิเสธคำขอหมายเลข: ${widget.requestID} หรือไม่?',
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
                                                      text: 'ยันยัน',
                                                      foregroundColor: Colors.red,
                                                      request: () => LeaveApprovalService().approval(widget.requestID, ApproveStatus.rejected.state, _textEditingController.text, null),
                                                      setError: setError,
                                                      onSuccess: () async {
                                                        Navigator.of(context1).pop();
                                                        await Future.delayed(const Duration(milliseconds: 200));
                                                        if (!context.mounted) return;
                                                        Navigator.of(context, rootNavigator: true).pop();
                                                        widget.onRejected();

                                                        NotificationService().sendApprovalResponseNotification('LEAVE_REQUEST', widget.requestID, 'REJECTED');
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
                                                                text: 'ยืนยันการอนุมัติคำขอลางานในครั้งนี้เท่านั้น',
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
                                              request: (pngByte) => LeaveApprovalService().approval(widget.requestID, ApproveStatus.approved.state, _textEditingController.text, pngByte),
                                              onSuccessResponse: (pngBytes, jsonData) {
                                                navigator.pop();
                                                widget.onApproved();

                                                NotificationService().sendApprovalResponseNotification('LEAVE_REQUEST', widget.requestID, 'APPROVED');
                                              },
                                            ));

                                            provider.setConfig(oldConfig);
                                          } else {
                                            FloatingPopup(
                                                title: 'อนุมัติคำขอ',
                                                description: 'คุณยืนยันที่จะอนุมัติคำขอหมายเลข: ${widget.requestID} หรือไม่?',
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
                                                      text: 'ยันยัน',
                                                      foregroundColor: Colors.red,
                                                      request: () => LeaveApprovalService().approval(widget.requestID, ApproveStatus.approved.state, _textEditingController.text, null),
                                                      setError: setError,
                                                      onSuccess: () async {
                                                        Navigator.of(context1).pop();
                                                        await Future.delayed(const Duration(milliseconds: 200));
                                                        if (!context.mounted) return;
                                                        Navigator.of(context, rootNavigator: true).pop();
                                                        widget.onApproved();

                                                        NotificationService().sendApprovalResponseNotification('LEAVE_REQUEST', widget.requestID, 'REJECTED');
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
                )
            ],
          );
        }
      ),
    );
  }
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

Future<Response> mockData() async {
  await Future.delayed(
    const Duration(milliseconds: 200),
  );

  return Response(
    requestOptions: RequestOptions(path: '/api/attendance_request/detail'),
    statusCode: 200,
    data: {
      'request-detail': {
        'leave-type': 'sick',
        'date-from': '2026-02-15T18:00:45.621Z',
        'date-to': '2026-02-28T18:00:45.621Z',
        'from-date-morning': true,
        'to-date-morning': false,
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
        'request-date': '2026-02-18T18:00:45.621Z',
      },
      'approve-detail': {
        'status': 'pending',
        'approve-role': 'คณบดี',
        'approver': 'ด้วยดี ตามไท',
        'reason': 'ดีมาก',
        'approve-date': '2026-02-01T08:00:00.000Z',
      }
    },
  );
}