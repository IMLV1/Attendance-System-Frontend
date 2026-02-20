import 'package:attendance_system/core/data/api/max_leave_api.dart';
import 'package:attendance_system/core/data/entities/max_leave_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/number_service_popup.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

Future<Response> mockData() async {
  await Future.delayed(const Duration(milliseconds: 500));

  return Response(
      requestOptions: RequestOptions(path: '/mock/user'),
      statusCode: 200,
      data: {
        'sick': 60,
        'personal': 45,
        'vacation': 10.5,
        'maternity': 180,
        'paternity': 60,
        'parental': 150
      }
  );
}

class MaxLeave extends StatefulWidget {

  final String id;
  final String title;

  const MaxLeave({super.key, required this.id, this.title = 'จำนวนวันลา'});

  @override
  State<StatefulWidget> createState() => _MaxLeaveState();
}

class _MaxLeaveState extends State<MaxLeave> {

  MaxLeaveModel? maxLeave;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      content: AppScaffold(
        header: Header.subHeader(
          context,
          title: widget.title
        ),
        content: SafeArea(
          child: Container(
            color: AppColors.backgroundColor,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
              child: Column(
                children: [
                  Expanded(
                    child: ServiceLoader(
                        request: () => MaxLeaveService().getData(widget.id),
                        onSuccess: (jsonData) {
                          final data = MaxLeaveModel.fromJson(jsonData);
                          setState(() {
                            maxLeave = data;
                          });
                        },
                      //child: Column(),
                        builder: () => SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: SeparatorCard(
                              separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                              children: [
                                IconTextValueButton(onPressed: () {
                                  NumberServicePopup(
                                      title: 'ลาป่วย',
                                      buttonLabel: 'บันทึก',
                                      fit: FlexFit.tight,
                                      suffixText: 'วัน',
                                      decimal: true,
                                      maxHeight: 700,
                                      decimalRange: 1,
                                      step: 0.5,
                                      currentValue: maxLeave!.sick,
                                      request: (value) => MaxLeaveService().updateMaxLeave(widget.id, maxLeave!.copyWith(sick: value)),
                                      onSuccess: (number) {
                                        setState(() {
                                          maxLeave = maxLeave?.copyWith(sick: number);
                                        });
                                      }
                                  ).showPopup(context);
                                }, icon: 'leave_sick.svg', label: 'ลาป่วย', value: '${NumberFormat("#,##0.#").format(maxLeave!.sick)} วัน'),
                                IconTextValueButton(onPressed: () {
                                  NumberServicePopup(
                                      title: 'ลากิจส่วนตัว',
                                      buttonLabel: 'บันทึก',
                                      fit: FlexFit.tight,
                                      suffixText: 'วัน',
                                      decimal: true,
                                      maxHeight: 700,
                                      decimalRange: 1,
                                      step: 0.5,
                                      currentValue: maxLeave!.personal,
                                      request: (value) => MaxLeaveService().updateMaxLeave(widget.id, maxLeave!.copyWith(personal: value)),
                                      onSuccess: (number) {
                                        setState(() {
                                          maxLeave = maxLeave?.copyWith(personal: number);
                                        });
                                      }
                                  ).showPopup(context);
                                }, icon: 'leave_personal.svg', label: 'ลากิจส่วนตัว', value: '${NumberFormat("#,##0.#").format(maxLeave!.personal)} วัน'),
                                IconTextValueButton(onPressed: () {
                                  NumberServicePopup(
                                      title: 'ลาพักผ่อน',
                                      buttonLabel: 'บันทึก',
                                      fit: FlexFit.tight,
                                      suffixText: 'วัน',
                                      decimal: true,
                                      maxHeight: 700,
                                      decimalRange: 1,
                                      step: 0.5,
                                      currentValue: maxLeave!.vacation,
                                      request: (value) => MaxLeaveService().updateMaxLeave(widget.id, maxLeave!.copyWith(vacation: value)),
                                      onSuccess: (number) {
                                        setState(() {
                                          maxLeave = maxLeave?.copyWith(vacation: number);
                                        });
                                      }
                                  ).showPopup(context);
                                }, icon: 'leave_vacation.svg', label: 'ลาพักผ่อน', value: '${NumberFormat("#,##0.#").format(maxLeave!.vacation)} วัน'),
                                IconTextValueButton(onPressed: () {
                                  NumberServicePopup(
                                      title: 'ลาคลอดบุตร',
                                      buttonLabel: 'บันทึก',
                                      fit: FlexFit.tight,
                                      suffixText: 'วัน',
                                      decimal: true,
                                      maxHeight: 700,
                                      decimalRange: 1,
                                      step: 0.5,
                                      currentValue: maxLeave!.maternity,
                                      request: (value) => MaxLeaveService().updateMaxLeave(widget.id, maxLeave!.copyWith(maternity: value)),
                                      onSuccess: (number) {
                                        setState(() {
                                          maxLeave = maxLeave?.copyWith(maternity: number);
                                        });
                                      }
                                  ).showPopup(context);
                                }, icon: 'leave_maternity.svg', label: 'ลาคลอดบุตร', value: '${NumberFormat("#,##0.#").format(maxLeave!.maternity)} วัน'),
                                IconTextValueButton(onPressed: () {
                                  NumberServicePopup(
                                      title: 'ลาช่วยเหลือภริยาคลอดบุตร',
                                      buttonLabel: 'บันทึก',
                                      fit: FlexFit.tight,
                                      suffixText: 'วัน',
                                      decimal: true,
                                      maxHeight: 700,
                                      decimalRange: 1,
                                      step: 0.5,
                                      currentValue: maxLeave!.paternity,
                                      request: (value) => MaxLeaveService().updateMaxLeave(widget.id, maxLeave!.copyWith(paternity: value)),
                                      onSuccess: (number) {
                                        setState(() {
                                          maxLeave = maxLeave?.copyWith(paternity: number);
                                        });
                                      }
                                  ).showPopup(context);
                                }, icon: 'leave_paternity.svg', label: 'ลาช่วยเหลือภริยาคลอดบุตร', value: '${NumberFormat("#,##0.#").format(maxLeave!.paternity)} วัน'),
                                IconTextValueButton(onPressed: () {
                                  NumberServicePopup(
                                      title: 'ลากิจเพื่อเลี้ยงดูบุตร',
                                      buttonLabel: 'บันทึก',
                                      fit: FlexFit.tight,
                                      suffixText: 'วัน',
                                      decimal: true,
                                      maxHeight: 700,
                                      decimalRange: 1,
                                      step: 0.5,
                                      currentValue: maxLeave!.parental,
                                      request: (value) => MaxLeaveService().updateMaxLeave(widget.id, maxLeave!.copyWith(parental: value)),
                                      onSuccess: (number) {
                                        setState(() {
                                          maxLeave = maxLeave?.copyWith(parental: number);
                                        });
                                      }
                                  ).showPopup(context);
                                }, icon: 'leave_parental.svg', label: 'ลากิจเพื่อเลี้ยงดูบุตร', value: '${NumberFormat("#,##0.#").format(maxLeave!.parental)} วัน'),
                              ],
                            )
                        ),
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