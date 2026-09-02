import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/services/max_leave/max_leave_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/number_input_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class SetMaxLeave extends StatefulWidget {

  final MaxLeaveModel maxLeave;

  const SetMaxLeave({super.key, required this.maxLeave});

  @override
  State<StatefulWidget> createState() => _SetMaxLeaveState();
}

class _SetMaxLeaveState extends State<SetMaxLeave> {

  MaxLeaveModel? maxLeave;

  @override
  void initState() {
    super.initState();
    maxLeave = widget.maxLeave;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        // 🚩 (2026-08-27) เดิมที่นี่เป็น AppScaffold ซ้อน AppScaffold
        // ตัวนอกไม่มีแถบหัวและไม่ได้ทำอะไรเลยนอกจากซ้อน Scaffold ให้อีกชั้น
        // (พื้นหลัง/รูโหว่ safe area/ค่า maxWidth คิดสองรอบ) — เหลือชั้นเดียว
        maxWidth: Responsive.widthFor(ContentShape.form),
        header: Header.subHeader(
          context,
          title: 'กำหนดจำนวนวันลา',
          onBack: () {
            Navigator.of(context).pop(maxLeave);
          }
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
                            child: maxLeave == null ? const Center(child: CupertinoActivityIndicator())
                                : SingleChildScrollView(
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                physics: AlwaysScrollableScrollPhysics(),
                                child: SeparatorCard(
                                  separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                                  children: [
                                    IconTextValueButton(onPressed: () {
                                      NumberInputPopup(
                                          title: 'ลาป่วย',
                                          buttonLabel: 'บันทึก',
                                          fit: FlexFit.tight,
                                          suffixText: 'วัน',
                                          decimal: true,
                                          maxHeight: 700,
                                          step: 0.5,
                                          currentValue: maxLeave!.sick,
                                          onSubmit: (number) {
                                            setState(() {
                                              maxLeave = maxLeave?.copyWith(sick: number);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, icon: 'leave_sick.svg', label: 'ลาป่วย', value: '${NumberFormat("#,##0.#").format(maxLeave!.sick)} วัน'),
                                    IconTextValueButton(onPressed: () {
                                      NumberInputPopup(
                                          title: 'ลากิจส่วนตัว',
                                          buttonLabel: 'บันทึก',
                                          fit: FlexFit.tight,
                                          suffixText: 'วัน',
                                          decimal: true,
                                          maxHeight: 700,
                                          step: 0.5,
                                          currentValue: maxLeave!.personal,
                                          onSubmit: (number) {
                                            setState(() {
                                              maxLeave = maxLeave?.copyWith(personal: number);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, icon: 'leave_personal.svg', label: 'ลากิจส่วนตัว', value: '${NumberFormat("#,##0.#").format(maxLeave!.personal)} วัน'),
                                    IconTextValueButton(onPressed: () {
                                      NumberInputPopup(
                                          title: 'ลาพักผ่อน',
                                          buttonLabel: 'บันทึก',
                                          fit: FlexFit.tight,
                                          suffixText: 'วัน',
                                          decimal: true,
                                          maxHeight: 700,
                                          step: 0.5,
                                          currentValue: maxLeave!.vacation,
                                          onSubmit: (number) {
                                            setState(() {
                                              maxLeave = maxLeave?.copyWith(vacation: number);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, icon: 'leave_vacation.svg', label: 'ลาพักผ่อน', value: '${NumberFormat("#,##0.#").format(maxLeave!.vacation)} วัน'),
                                    IconTextValueButton(onPressed: () {
                                      NumberInputPopup(
                                          title: 'ลาคลอดบุตร',
                                          buttonLabel: 'บันทึก',
                                          fit: FlexFit.tight,
                                          suffixText: 'วัน',
                                          decimal: true,
                                          maxHeight: 700,
                                          step: 0.5,
                                          currentValue: maxLeave!.maternity,
                                          onSubmit: (number) {
                                            setState(() {
                                              maxLeave = maxLeave?.copyWith(maternity: number);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, icon: 'leave_maternity.svg', label: 'ลาคลอดบุตร', value: '${NumberFormat("#,##0.#").format(maxLeave!.maternity)} วัน'),
                                    IconTextValueButton(onPressed: () {
                                      NumberInputPopup(
                                          title: 'ลาช่วยเหลือภริยาคลอดบุตร',
                                          buttonLabel: 'บันทึก',
                                          fit: FlexFit.tight,
                                          suffixText: 'วัน',
                                          decimal: true,
                                          maxHeight: 700,
                                          step: 0.5,
                                          currentValue: maxLeave!.paternity,
                                          onSubmit: (number) {
                                            setState(() {
                                              maxLeave = maxLeave?.copyWith(paternity: number);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, icon: 'leave_paternity.svg', label: 'ลาไปช่วยเหลือภริยาที่คลอดบุตร', value: '${NumberFormat("#,##0.#").format(maxLeave!.paternity)} วัน'),
                                    IconTextValueButton(onPressed: () {
                                      NumberInputPopup(
                                          title: 'ลากิจเพื่อเลี้ยงดูบุตร',
                                          buttonLabel: 'บันทึก',
                                          fit: FlexFit.tight,
                                          suffixText: 'วัน',
                                          decimal: true,
                                          maxHeight: 700,
                                          step: 0.5,
                                          currentValue: maxLeave!.parental,
                                          onSubmit: (number) {
                                            setState(() {
                                              maxLeave = maxLeave?.copyWith(parental: number);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, icon: 'leave_parental.svg', label: 'ลากิจเพื่อเลี้ยงดูบุตร', value: '${NumberFormat("#,##0.#").format(maxLeave!.parental)} วัน'),
                                    IconTextValueButton(onPressed: () {
                                      NumberInputPopup(
                                          title: 'ลาอุปสมบทหรือการลาไปประกอบพิธีฮัจย์',
                                          buttonLabel: 'บันทึก',
                                          fit: FlexFit.tight,
                                          suffixText: 'วัน',
                                          decimal: true,
                                          maxHeight: 700,
                                          step: 0.5,
                                          currentValue: maxLeave!.ordination,
                                          onSubmit: (number) {
                                            setState(() {
                                              maxLeave = maxLeave?.copyWith(ordination: number);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, icon: 'leave.svg', label: 'ลาอุปสมบทหรือการลาไปประกอบพิธีฮัจย์', value: '${NumberFormat("#,##0.#").format(maxLeave!.ordination)} วัน'),
                                    IconTextValueButton(onPressed: () {
                                      NumberInputPopup(
                                          title: 'ลาเข้ารับการตรวจเลือกเตรียมทหาร',
                                          buttonLabel: 'บันทึก',
                                          fit: FlexFit.tight,
                                          suffixText: 'วัน',
                                          decimal: true,
                                          maxHeight: 700,
                                          step: 0.5,
                                          currentValue: maxLeave!.military,
                                          onSubmit: (number) {
                                            setState(() {
                                              maxLeave = maxLeave?.copyWith(military: number);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, icon: 'leave.svg', label: 'ลาเข้ารับการตรวจเลือกเตรียมทหาร', value: '${NumberFormat("#,##0.#").format(maxLeave!.military)} วัน'),
                                    IconTextValueButton(onPressed: () {
                                      NumberInputPopup(
                                          title: 'ลาไปฟื้นฟูสมรรถภาพด้านอาชีพ',
                                          buttonLabel: 'บันทึก',
                                          fit: FlexFit.tight,
                                          suffixText: 'วัน',
                                          decimal: true,
                                          maxHeight: 700,
                                          step: 0.5,
                                          currentValue: maxLeave!.rehabilitation,
                                          onSubmit: (number) {
                                            setState(() {
                                              maxLeave = maxLeave?.copyWith(rehabilitation: number);
                                            });
                                          }
                                      ).showPopup(context);
                                    }, icon: 'leave.svg', label: 'ลาไปฟื้นฟูสมรรถภาพด้านอาชีพ', value: '${NumberFormat("#,##0.#").format(maxLeave!.rehabilitation)} วัน'),
                                  ],
                                )
                            ),
                          )
                        ]
                    )
                )
            )
        )
    );
  }

}