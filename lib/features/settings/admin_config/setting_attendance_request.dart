import 'package:attendance_system/core/data/api/config_attendance_request_api.dart';
import 'package:attendance_system/core/data/entities/config_attendance_request_model.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/popup/floating_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/toggle_switch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

Future<Response> mockData() async {
  await Future.delayed(const Duration(milliseconds: 200));

  return Response(
      requestOptions: RequestOptions(path: '/mock/user'),
      statusCode: 200,
      data: {
        'request-need-signature': true,
        'approve-need-signature': true,
        'specify-approval-reason': true,
        'specify-remark': false,
        'required-remark': true,
        'evidence-file': true,
        'required-evidence-file': true,
      }
  );
}

class SettingAttendanceRequest extends StatefulWidget {
  const SettingAttendanceRequest({super.key});

  @override
  State<StatefulWidget> createState() => _SettingAttendanceRequestState();
}

class _SettingAttendanceRequestState extends State<SettingAttendanceRequest> {

  ConfigAttendanceRequestModel? initData;
  ConfigAttendanceRequestModel? data;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        header: Header.subHeader(
            context, title: 'ตั้งค่าการขออนุมัติเวลา',
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
                            request: () => ConfigAttendanceRequestService().update(data!),
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
                                  request: () => ConfigAttendanceRequestService().getData(),
                                  onSuccess: (jsonData) {
                                    setState(() {
                                      final data = ConfigAttendanceRequestModel.fromJson(jsonData);
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
                                              ),
                                              ToggleSwitch(
                                                icon: 'icon_specify_approval.svg',
                                                label: 'ระบุเหตุผลการอนุมัติ',
                                                value: data!.specifyApprovalReason,
                                                onChanged: (value) {
                                                  setState(() {
                                                    data = data!.copyWith(specifyApprovalReason: value);
                                                  });
                                                },
                                              )
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