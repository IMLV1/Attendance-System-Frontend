import 'package:attendance_system/services/max_leave/max_leave_model.dart';
import 'package:attendance_system/services/max_leave/max_leave_service.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/number_service_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// การ์ด "จำนวนวันลาสูงสุด" ของผู้ใช้คนหนึ่ง — 6 ประเภทการลา แก้ทีละแถว
///
/// 🚩 (2026-08-27) เดิมเป็นหน้าเต็ม (`MaxLeave`) ที่ `user_info` push ไปอีกชั้น
/// ทั้งที่มันเป็นหน้าเดียวกับ `user_info` ในทุกแง่ — จำนวนแถวคงที่ กดแล้วเปิด
/// popup ยิง `updateMaxLeave` ทันทีต่อแถว ไม่มีปุ่มบันทึกรวม เหมือน 7 ช่อง
/// ข้อมูลส่วนตัวข้างบนเป๊ะ จึงยุบมาเป็นการ์ดในหน้าเดียวกัน
///
/// (ต่างจาก `AssignRole` ที่ยังแยกเป็น popup เพราะยาวตามจำนวนตำแหน่งและเป็น
/// batch-save — เอามาปนกับหน้าที่เซฟทันทีจะทำให้ของหายเงียบเมื่อลืมกดบันทึก)
class MaxLeaveSection extends StatefulWidget {

  final String id;

  const MaxLeaveSection({super.key, required this.id});

  @override
  State<MaxLeaveSection> createState() => _MaxLeaveSectionState();
}

/// ประเภทการลาหนึ่งแถว — แยกเป็นข้อมูลแทนที่จะก๊อป widget หกรอบ
/// (เดิมหกบล็อกต่างกันแค่ชื่อ/ไอคอน/ฟิลด์ ~19 บรรทัดต่อบล็อก)
typedef _LeaveField = ({
  String label,
  String icon,
  double Function(MaxLeaveModel model) read,
  MaxLeaveModel Function(MaxLeaveModel model, double value) write,
});

double _readSick(MaxLeaveModel m) => m.sick;
double _readPersonal(MaxLeaveModel m) => m.personal;
double _readVacation(MaxLeaveModel m) => m.vacation;
double _readMaternity(MaxLeaveModel m) => m.maternity;
double _readPaternity(MaxLeaveModel m) => m.paternity;
double _readParental(MaxLeaveModel m) => m.parental;

MaxLeaveModel _writeSick(MaxLeaveModel m, double v) => m.copyWith(sick: v);
MaxLeaveModel _writePersonal(MaxLeaveModel m, double v) => m.copyWith(personal: v);
MaxLeaveModel _writeVacation(MaxLeaveModel m, double v) => m.copyWith(vacation: v);
MaxLeaveModel _writeMaternity(MaxLeaveModel m, double v) => m.copyWith(maternity: v);
MaxLeaveModel _writePaternity(MaxLeaveModel m, double v) => m.copyWith(paternity: v);
MaxLeaveModel _writeParental(MaxLeaveModel m, double v) => m.copyWith(parental: v);

const List<_LeaveField> _fields = [
  (label: 'ลาป่วย', icon: 'leave_sick.svg', read: _readSick, write: _writeSick),
  (label: 'ลากิจส่วนตัว', icon: 'leave_personal.svg', read: _readPersonal, write: _writePersonal),
  (label: 'ลาพักผ่อน', icon: 'leave_vacation.svg', read: _readVacation, write: _writeVacation),
  (label: 'ลาคลอดบุตร', icon: 'leave_maternity.svg', read: _readMaternity, write: _writeMaternity),
  (label: 'ลาช่วยเหลือภริยาคลอดบุตร', icon: 'leave_paternity.svg', read: _readPaternity, write: _writePaternity),
  (label: 'ลากิจเพื่อเลี้ยงดูบุตร', icon: 'leave_parental.svg', read: _readParental, write: _writeParental),
];

/// 🚩 รับได้แค่จำนวนเต็มกับครึ่งวัน — ค่าอื่นปัดเป็นจำนวนเต็ม
/// (ลอกพฤติกรรมเดิมมาตรงๆ เดิมเขียนซ้ำอยู่ในทั้งหกบล็อก)
double _snap(double value) => value % 1 == 0.5 ? value : value.round().toDouble();

class _MaxLeaveSectionState extends State<MaxLeaveSection> {

  MaxLeaveModel? maxLeave;

  final _format = NumberFormat('#,##0.#');

  @override
  Widget build(BuildContext context) {
    return ServiceLoader(
      request: () => MaxLeaveService().getData(widget.id),
      onSuccess: (jsonData) {
        final data = MaxLeaveModel.fromJson(jsonData);
        setState(() => maxLeave = data);
      },
      builder: () => SeparatorCard(
        separatorPadding: const EdgeInsets.only(left: 45, right: 15),
        children: [for (final field in _fields) _row(context, field)],
      ),
    );
  }

  Widget _row(BuildContext context, _LeaveField field) {
    final model = maxLeave!;
    final current = field.read(model);

    return IconTextValueButton(
      icon: field.icon,
      label: field.label,
      value: '${_format.format(current)} วัน',
      onPressed: () {
        NumberServicePopup(
          title: field.label,
          buttonLabel: 'บันทึก',
          fit: FlexFit.tight,
          suffixText: 'วัน',
          decimal: true,
          maxHeight: 700,
          decimalRange: 1,
          step: 0.5,
          currentValue: current,
          request: (value) => MaxLeaveService()
              .updateMaxLeave(widget.id, field.write(model, _snap(value))),
          onSuccess: (number) {
            setState(() => maxLeave = field.write(maxLeave!, _snap(number)));
          },
        ).showPopup(context);
      },
    );
  }
}
