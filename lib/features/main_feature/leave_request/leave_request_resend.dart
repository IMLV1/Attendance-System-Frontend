import 'package:attendance_system/features/main_feature/leave_request/date_select.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_type.dart';
import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:attendance_system/services/leave/leave_service.dart';
import 'package:attendance_system/services/notification/notification_service.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/service_signature_page.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:attendance_system/shared/widgets/utils/text_button.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

class LeaveRequestResend extends StatefulWidget {

  final String requestId;
  final LeaveType leaveType;
  final LeaveDate leaveDate;
  final String remark;
  final List<NetworkFile> allFiles;
  final void Function() onResend;

  const LeaveRequestResend({
    super.key,
    required this.requestId,
    required this.leaveType,
    required this.leaveDate,
    required this.remark,
    required this.allFiles,
    required this.onResend,
  });

  @override
  State<LeaveRequestResend> createState() => _LeaveRequestResendState();
}

class _LeaveRequestResendState extends State<LeaveRequestResend> {

  int limitFileSize = 52428800;

  String? remark;
  List<NetworkFile> oldFiles = [];
  List<PlatformFile> allFiles = [];

  bool submitted = false;
  bool confirmed = false;

  LeaveInfoModel? leaveStatsInfo;

  bool _isConfigured = false;

  double getLeaveDays() {
    double leaveDays = widget.leaveDate.toDate!.difference(widget.leaveDate.fromDate!).inDays + 1;
    double period = (widget.leaveDate.fromDateMorning ? 0 : -0.5) + (widget.leaveDate.toDateMorning ? -0.5 : 0);
    double finalLeaves = leaveDays + period;

    return finalLeaves;
  }

  double getRemainLeaveDays() {
    return (leaveStatsInfo?.max ?? 0) - (leaveStatsInfo?.used ?? 0);
  }

  final MenuController _menuController = MenuController();
  final TextEditingController _textEditingController = TextEditingController();

  LeaveSetting? setting;

  @override
  void initState() {
    super.initState();

    remark = widget.remark;
    oldFiles = [...widget.allFiles];

    setting = widget.leaveType.getSetting(context);

    _textEditingController.text = widget.remark;
  }

  @override
  Widget build(BuildContext context) {

    return ServiceUpdater(
      request: () => LeaveRequestService().getLeaveInfo(widget.leaveType),
      onSuccessResponse: (jsonData) {
        setState(() {
          leaveStatsInfo = LeaveInfoModel.fromJson(jsonData);
        });
      },
      fetchOnInit: true,
      builder: (trigger, state, errorMessage) {
        return (state == .loading) ?
        CupertinoActivityIndicator() :
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
          child: ServiceUpdater(
              request: () => LeaveRequestService().resendRequest(widget.requestId, remark!, oldFiles, allFiles, null),
              onSuccessResponse: (jsonData) {
                Navigator.of(context, rootNavigator: true).pop();
                widget.onResend();

                NotificationService().sendRequestNotification('APPROVER_LEAVE', widget.requestId);
              },
              builder: (trigger, state, errorMessage) {

                final bool isApiLoading = (state == ServiceUpdatorState.loading);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (ModalRoute.of(context)?.isCurrent != true) return;

                  final provider = PopupProvider.of(context);

                  // 👈 เปลี่ยนเงื่อนไขมาเช็ค !_isConfigured แทนการเช็ค trigger
                  if (provider.config.isLoading != isApiLoading || !_isConfigured) {

                    _isConfigured = true; // 👈 สั่งให้บันทึกว่าตั้งค่าปุ่มไปแล้ว จะได้ไม่วนลูปอีก

                    provider.setConfig(
                      // copyWith ดีมากตรงที่มันจะเก็บ Title เดิมไว้ แต่เปลี่ยนแค่ปุ่มกับ Loading
                        provider.config.copyWith(
                          isLoading: isApiLoading,
                          buttonAction: (ctx) async {
                            setState(() {
                              submitted = true;
                            });

                            if (setting!.requiredRemark && _textEditingController.text.isEmpty) return;
                            if (setting!.requiredEvidenceFile && allFiles.isEmpty && oldFiles.isEmpty) return;

                            if (allFiles.fold(0, (sum, file) => sum + file.size) + oldFiles.fold(0, (sum, file) => sum + file.fileSize) > limitFileSize) return;

                            if (getLeaveDays() > getRemainLeaveDays() && !confirmed) {

                              provider.setConfig(provider.config.copyWith(
                                buttonColor: Colors.red,
                                buttonLabel: 'ยืนยัน'
                              ));

                              confirmed = true;
                              return;
                            }

                            if (setting!.requestNeedSignature) {
                              final provider = PopupProvider.of(context);
                              final oldConfig = provider.config;

                              provider.setConfig(PopupConfig(
                                title: 'ลายเซ็น',
                                buttonLabel: 'ส่ง',
                                maxHeight: 700
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
                                request: (pngByte) => LeaveRequestService().resendRequest(widget.requestId, remark!, oldFiles, allFiles, pngByte),
                                onSuccessResponse: (pngBytes, jsonData) {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  widget.onResend();

                                  NotificationService().sendRequestNotification('APPROVER_LEAVE', widget.requestId);
                                },
                              ));

                              provider.setConfig(oldConfig);
                            } else {
                              trigger();
                            }
                          }, // ผูกปุ่มขวาบนเข้ากับ trigger ของหน้านี้!
                        )
                    );
                  }
                });

                return Column(
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
                    Column(
                      spacing: 13,
                      children: [
                        Column(
                          spacing: 6,
                          children: [
                            SeparatorCard(
                              children: [
                                TextButton(
                                  label: widget.leaveType.display,
                                  color: Colors.grey,
                                  onPressed: null,
                                  arrow: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                            padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
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
                                              '${DateFormat.MMMd('th_TH').format(widget.leaveDate.fromDate!)} ${num.parse(DateFormat.y('th_TH').format(widget.leaveDate.fromDate!)) + 543} ${widget.leaveDate.fromDateMorning ? 'เช้า' : 'เย็น'}',
                                              style: TextStyle(
                                                  color: Colors.grey,
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
                                              '${DateFormat.MMMd('th_TH').format(widget.leaveDate.toDate!)} ${num.parse(DateFormat.y('th_TH').format(widget.leaveDate.toDate!)) + 543} ${widget.leaveDate.toDateMorning ? 'เช้า' : 'เย็น'}',
                                              style: TextStyle(
                                                  color: Colors.grey,
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
                        ),
                        if (setting!.specifyRemark)
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
                        if (setting!.evidenceFile)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: (submitted &&
                                      setting?.requiredEvidenceFile == true &&
                                      ((allFiles.isEmpty && oldFiles.isEmpty) || (allFiles.fold(0, (sum, file) => sum + file.size) + oldFiles.fold(0, (sum, file) => sum + file.fileSize) > limitFileSize)))
                                      ? Border.all(
                                    color: Colors.red,
                                    width: 1.5,
                                  ) : null,
                                ),
                                child: SeparatorCard(
                                  separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                                  children: [
                                    MenuAnchor(
                                      useRootOverlay: true,
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
                                        child: (allFiles.isEmpty && oldFiles.isEmpty) ? Padding(
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

                                                ...oldFiles.map((file) {

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
                                                              Text(file.fileName,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.w800
                                                                  )
                                                              ),
                                                              Text('ขนาด ${Utils.formatBytes(file.fileSize)}',
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
                                                                oldFiles.remove(file);
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
                                                }),

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
                                child: (submitted && setting!.requiredEvidenceFile && ((allFiles.isEmpty && oldFiles.isEmpty) || allFiles.fold(0, (sum, file) => sum + file.size) + oldFiles.fold(0, (sum, file) => sum + file.fileSize) > limitFileSize))
                                    ? Padding(
                                  padding: EdgeInsets.only(left: 13, top: 8),
                                  child: Text(
                                    (allFiles.fold(0, (sum, file) => sum + file.size) + oldFiles.fold(0, (sum, file) => sum + file.fileSize) > limitFileSize) ? 'ขนาดไฟล์รวมเกิน ${Utils.formatBytes(limitFileSize)}' : 'กรุณาแนบไฟล์',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ) : SizedBox(),
                              )
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
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
                                          text: 'คุณได้ใช้สิทธิ์การลาป่วยครบตามจำนวนที่กำหนดแล้ว หากคำขอนี้ได้รับการอนุมัติจำนวนวันลาของคุณจะเกินสิทธิ์ทั้งหมด ${getLeaveDays() - getRemainLeaveDays()} วัน ซึ่งอาจส่งผลต่อการคำนวณตัวชี้วัดผลการปฏิบัติงาน ',
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
                );
              }
          ),
        );
      },
    );
  }
}