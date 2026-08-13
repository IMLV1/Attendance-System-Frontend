import 'package:attendance_system/core/utils/navigation_guard.dart';
import 'package:attendance_system/features/settings/admin_config/admin_config_utils.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_model.dart';
import 'package:attendance_system/services/system_config/leave/config_leave_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/toggle_switch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<Response> mockData() async {
  await Future.delayed(const Duration(milliseconds: 200));

  return Response(
    requestOptions: RequestOptions(path: '/mock/user'),
    statusCode: 200,
    data: {
      'sick': {
        'request-need-signature': false,
        'approve-need-signature': true,
        'allow-retroactive': false,
        'specify-remark': true,
        'required-remark': true,
        'evidence-file': true,
        'required-evidence-file': true,
      },
      'personal': {
        'request-need-signature': false,
        'approve-need-signature': true,
        'allow-retroactive': false,
        'specify-remark': true,
        'required-remark': true,
        'evidence-file': true,
        'required-evidence-file': true,
      },
      'vacation': {
        'request-need-signature': false,
        'approve-need-signature': true,
        'allow-retroactive': false,
        'specify-remark': true,
        'required-remark': true,
        'evidence-file': true,
        'required-evidence-file': true,
      },
      'maternity': {
        'request-need-signature': false,
        'approve-need-signature': true,
        'allow-retroactive': false,
        'specify-remark': true,
        'required-remark': true,
        'evidence-file': true,
        'required-evidence-file': true,
      },
      'paternity': {
        'request-need-signature': false,
        'approve-need-signature': true,
        'allow-retroactive': false,
        'specify-remark': true,
        'required-remark': true,
        'evidence-file': true,
        'required-evidence-file': true,
      },
      'parental': {
        'request-need-signature': false,
        'approve-need-signature': true,
        'allow-retroactive': false,
        'specify-remark': true,
        'required-remark': true,
        'evidence-file': true,
        'required-evidence-file': true,
      },
    }
  );
}

class SettingLeaveType extends StatefulWidget {
  const SettingLeaveType({super.key});

  @override
  State<StatefulWidget> createState() => _SettingLeaveTypeState();

}

class _SettingLeaveTypeState extends State<SettingLeaveType> {

  bool _forcePop = false;
  ConfigLeaveModel? initData;
  ConfigLeaveModel? data;

  @override
  Widget build(BuildContext context) {
    final isDirty = data != null && !initData!.isSame(data!);

    // Update global navigation guard
    context.read<NavigationGuard>().update(
      isDirty: isDirty,
      onSave: () => ConfigLeaveService().update(data!),
      onDiscard: () {
        setState(() => _forcePop = true);
        context.read<NavigationGuard>().reset();
        Navigator.of(context).pop();
      },
    );

    return AppScaffold(
        header: Header.subHeader(
            context, title: 'ตั้งค่าประเภทการลา',
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
              onSave: () => ConfigLeaveService().update(data!),
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
                                  request: () => ConfigLeaveService().getData(),
                                  onSuccess: (jsonData) {
                                    setState(() {
                                      final data = ConfigLeaveModel.fromJson(jsonData);
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
                                            separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 15),
                                            children: [
                                              AppButton(
                                                icon: 'icon_sick.svg',
                                                title: 'ลาป่วย',
                                                weightTitle: FontWeight.normal,
                                                onPressed: () async {
                                                  LeaveSetting? setting = await Navigator.of(context).push(
                                                    MaterialPageRoute<LeaveSetting>(
                                                      builder: (_) => ConfigLeave(type: 'sick', name: 'ลาป่วย', data: data!.sick)
                                                    )
                                                  );

                                                  if (setting != null) {
                                                    data = data!.copyWith(sick: setting);
                                                  }
                                                },
                                              ),
                                              AppButton(
                                                icon: 'icon_leave_personal.svg',
                                                title: 'ลากิจส่วนตัว',
                                                weightTitle: FontWeight.normal,
                                                onPressed: () async {
                                                  LeaveSetting? setting = await Navigator.of(context).push(
                                                      MaterialPageRoute<LeaveSetting>(
                                                          builder: (_) => ConfigLeave(type: 'personal', name: 'ลากิจส่วนตัว', data: data!.personal)
                                                      )
                                                  );
                                                  if (setting != null) {
                                                    data = data!.copyWith(personal: setting);
                                                  }
                                                },
                                              ),
                                              AppButton(
                                                icon: 'icon_vacation.svg',
                                                title: 'ลาพักผ่อน',
                                                weightTitle: FontWeight.normal,
                                                onPressed: () async {
                                                  LeaveSetting? setting = await Navigator.of(context).push(
                                                      MaterialPageRoute<LeaveSetting>(
                                                          builder: (_) => ConfigLeave(type: 'vacation', name: 'ลาพักผ่อน', data: data!.vacation)
                                                      )
                                                  );

                                                  if (setting != null) {
                                                    data = data!.copyWith(vacation: setting);
                                                  }
                                                },
                                              ),
                                              AppButton(
                                                icon: 'icon_maternity_leave.svg',
                                                title: 'ลาคลอดบุตร',
                                                weightTitle: FontWeight.normal,
                                                onPressed: () async {
                                                  LeaveSetting? setting = await Navigator.of(context).push(
                                                      MaterialPageRoute<LeaveSetting>(
                                                          builder: (_) => ConfigLeave(type: 'maternity', name: 'ลาคลอดบุตร', data: data!.maternity)
                                                      )
                                                  );
                                                  if (setting != null) {
                                                    data = data!.copyWith(maternity: setting);
                                                  }
                                                },
                                              ),
                                              AppButton(
                                                icon: 'icon_leave_assist_childbirth.svg',
                                                title: 'ลาช่วยเหลือภริยาคลอดบุตร',
                                                weightTitle: FontWeight.normal,
                                                onPressed: () async {
                                                  LeaveSetting? setting = await Navigator.of(context).push(
                                                      MaterialPageRoute<LeaveSetting>(
                                                          builder: (_) => ConfigLeave(type: 'paternity', name: 'ลาช่วยเหลือภริยาคลอดบุตร', data: data!.paternity)
                                                      )
                                                  );
                                                  if (setting != null) {
                                                    data = data!.copyWith(paternity: setting);
                                                  }
                                                },
                                              ),
                                              AppButton(
                                                icon: 'icon_taking_care_child.svg',
                                                title: 'ลากิจเพื่อเลี้ยงดูบุตร',
                                                weightTitle: FontWeight.normal,
                                                onPressed: () async {
                                                  LeaveSetting? setting = await Navigator.of(context).push(
                                                      MaterialPageRoute<LeaveSetting>(
                                                          builder: (_) => ConfigLeave(type: 'parental', name: 'ลากิจเพื่อเลี้ยงดูบุตร', data: data!.parental)
                                                      )
                                                  );
                                                  if (setting != null) {
                                                    data = data!.copyWith(parental: setting);
                                                  }
                                                },
                                              ),
                                            ],
                                          )
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

class ConfigLeave extends StatefulWidget {

  final String type;
  final String name;
  final LeaveSetting data;

  const ConfigLeave({
    super.key,
    required this.type,
    required this.name,
    required this.data
  });

  @override
  State<StatefulWidget> createState() => _ConfigLeaveState();

}

class _ConfigLeaveState extends State<ConfigLeave> {

  bool _forcePop = false;
  LeaveSetting? data;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    final isDirty = data != null && !widget.data.isSame(data!);

    // Update global navigation guard
    context.read<NavigationGuard>().update(
      isDirty: isDirty,
      onSave: () async {
        setState(() => _forcePop = true);
        context.read<NavigationGuard>().reset();
        if (context.mounted) Navigator.pop(context, data);
        // 🚩 แก้: ต้องใส่ statusCode ให้ Response ด้วย — ServiceUpdater เช็ค res.statusCode!
        // (force-unwrap) ถ้าเป็น null จะ throw ทันที ทำให้กด "บันทึก" จากป็อปอัพยืนยัน
        // (ที่ trigger จาก bottom nav ผ่าน NavigationGuard.onSave) ขึ้น error เสมอ
        return Response(requestOptions: RequestOptions(path: ''), statusCode: 200);
      },
      onDiscard: () {
        setState(() => _forcePop = true);
        context.read<NavigationGuard>().reset();
        Navigator.pop(context, widget.data);
      },
    );

    return AppScaffold(
        header: Header.subHeader(
          context, title: 'ตั้งค่า: ${widget.name}',
          onBack: () {
            Navigator.of(context).maybePop();
          }
        ),
        content: PopScope(
          canPop: _forcePop || (data == null || widget.data.isSame(data!)),
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            AdminConfigUtils.showSaveConfirmation(
              context: context,
              onSave: () async {
                return Response(requestOptions: RequestOptions(path: ''), statusCode: 200);
              },
              onDiscard: () {
                setState(() => _forcePop = true);
                Navigator.pop(context, widget.data);
              },
              onNavigateBack: () {
                setState(() => _forcePop = true);
                if (context.mounted) Navigator.pop(context, data);
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
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          spacing: 13,
                          children: [
                            SeparatorCard(
                              separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                              children: [
                                ToggleSwitch(
                                  icon: 'icon_request_signature.svg',
                                  label: 'ส่งคำขอต้องการลายเซ็น',
                                  value: data!.requestNeedSignature,
                                  onChanged: (value) {
                                    setState(() {
                                      data = data!.copyWith(requestNeedSignature: value);
                                    });
                                  },
                                ),
                                ToggleSwitch(
                                  icon: 'icon_request_signature.svg',
                                  label: 'อนุมัติต้องการลายเซ็น',
                                  value: data!.approveNeedSignature,
                                  onChanged: (value) {
                                    setState(() {
                                      data = data!.copyWith(approveNeedSignature: value);
                                    });
                                  },
                                )
                              ],
                            ),
                            SeparatorCard(
                              separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                              children: [
                                ToggleSwitch(
                                  icon: 'allow_retroactive.svg',
                                  label: 'อนุญาติให้ลาย้อนหลัง',
                                  value: data!.allowRetroactive,
                                  onChanged: (value) {
                                    setState(() {
                                      data = data!.copyWith(allowRetroactive: value);
                                    });
                                  },
                                ),
                              ],
                            ),
                            SeparatorCard(
                              separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                              children: [
                                ToggleSwitch(
                                  icon: 'icon_specify_approval.svg',
                                  label: 'การระบุหมายเหตุ',
                                  value: data!.specifyRemark,
                                  subValue: data!.requiredRemark,
                                  subSwitch: true,
                                  onChanged: (value) {
                                    setState(() {
                                      data = data!.copyWith(specifyRemark: value);
                                      if (!value) data = data!.copyWith(requiredRemark: false);
                                    });
                                  },
                                  subLabel: 'จำเป็นต้องระบุ',
                                  onSubChanged: (value) {
                                    setState(() {
                                      data = data!.copyWith(requiredRemark: value);
                                    });
                                  },
                                ),
                                ToggleSwitch(
                                  icon: 'icon_attach_evidence.svg',
                                  label: 'แนบไฟล์หลักฐาน',
                                  subSwitch: true,
                                  value: data!.evidenceFile,
                                  subValue: data!.requiredEvidenceFile,
                                  onChanged: (value) {
                                    setState(() {
                                      data = data!.copyWith(evidenceFile: value);
                                      if (!value) data = data!.copyWith(requiredEvidenceFile: false);
                                    });
                                  },
                                  subLabel: 'จำเป็นต้องแนบ',
                                  onSubChanged: (value) {
                                    setState(() {
                                      data = data!.copyWith(requiredEvidenceFile: value);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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