import 'package:attendance_system/features/main_feature/statistic/statistic_body.dart';
import 'package:attendance_system/features/settings/personnel_info/choose_personnel.dart';
import 'package:attendance_system/services/personnel_info/personnel_info_model.dart';
import 'package:attendance_system/services/personnel_info/personnel_statistic_service.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:flutter/material.dart';

/// แท็บ "สถิติ" ในหน้าข้อมูลบุคลากร — เนื้อหาเดียวกับหน้า `/statistic` ของตัวเอง
///
/// 🚩 (2026-08-27) เดิมไฟล์นี้ถือสำเนาของทั้งหน้าไว้เอง (~300 บรรทัด) ตอน Phase 3
/// ไปปรับ `/statistic` ให้จัดวางตามขนาดจอ หน้านี้เลยค้างอยู่กับหน้าตาเดิมทันที
/// — ตัวกรองปียังเป็นข้อความเล็กๆ ลอยอยู่บนหัว ไม่ใช่การ์ดในแถวเดียวกับ KPI
/// และการ์ด "การมาทำงาน"/"การลางาน" ยังเรียงลงล่างตลอดแม้บนจอกว้าง
///
/// ตอนนี้เหลือแค่สองอย่างที่ต่างกันจริงๆ: service ที่ยิง (มี `personnelId`)
/// กับการ์ดบอกว่ากำลังดูใครอยู่
class PersonnelStatistic extends StatefulWidget {

  final PersonnelInfoModel personnel;

  /// ฝังเนื้อหาลงในคอลัมน์ขวาของ master-detail แทนการเป็นหน้าเต็ม
  /// — ไม่มีแถบหัวและปุ่ม back เพราะรายการทางซ้ายทำหน้าที่นำทางแทนแล้ว
  final bool embedded;

  const PersonnelStatistic({super.key, required this.personnel, this.embedded = false});

  @override
  State<StatefulWidget> createState() => _PersonnelStatisticState();

}

class _PersonnelStatisticState extends State<PersonnelStatistic> {

  late PersonnelInfoModel personnel = widget.personnel;

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _body(context);

    return AppScaffold(
        header: Header.subHeader(
            context,
            title: 'สถิติ',
            onBack: () {
              Navigator.of(context).pop(personnel);
            }
        ),
      content: _body(context),
    );
  }

  /// เนื้อหาล้วนๆ ไม่รวมแถบหัว — ใช้ทั้งตอนเป็นหน้าเต็มและตอนถูกฝัง
  /// ในคอลัมน์ขวาของ master-detail
  Widget _body(BuildContext context) {
    return SafeArea(
      child: StatisticBody(
        // เปลี่ยนคน = สร้าง widget ใหม่ทั้งตัว state เก่าจึงหายไปเอง แล้ว
        // `fetchOnInit` ยิงชุดใหม่ให้ — เดิมต้องไล่เคลียร์ค่าเดิมทีละฟิลด์
        // (statistic / workingHour / ช่วงปีที่เลือกได้) ซึ่งลืมได้ง่าย
        key: ValueKey(personnel.id),
        requests: (yearFilter) => [
          () => PersonnelStatisticService().getStatistic(personnelId: personnel.id, year: yearFilter),
          () => PersonnelStatisticService().getWorkingHour(personnelId: personnel.id),
          () => PersonnelStatisticService().getFilterRange(personnelId: personnel.id),
        ],
        header: _personnelCard(context),
      ),
    );
  }

  Widget _personnelCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 14),
      child: SeparatorCard(
        children: [
          UserInfoButton(
            arrow: !widget.embedded,
            icon: Image.network(
              personnel.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.asset('assets/images/profile.png'),
            ),
            title: personnel.nameTH,
            subTitle: personnel.nameEN,
            roles: [
              ...personnel.roles,
              Role(id: '0000000000', name: personnel.initRole, color: Color(0xFF535353))
            ],
            // 🚩 (2026-08-26) ในโหมด master-detail (จอกว้าง) รายการคนอยู่ที่แถบ
            // ซ้ายแล้ว การ์ดนี้เป็นแค่ป้ายบอกว่ากำลังดูใครอยู่ ถ้าปล่อยให้กดเลือกคน
            // ได้ด้วยจะได้สองที่ที่เลือกคนแต่ไม่รู้จักกัน — กดจากการ์ดแล้วเนื้อหา
            // เปลี่ยน แต่รายการซ้ายยังไฮไลต์คนเดิม ไม่มีทางรู้ว่าดูใครอยู่กันแน่
            //
            // `onPressed: null` ทำให้ UserInfoButton กลายเป็นโหมดแสดงผลอย่างเดียว
            // (ไม่มี ripple) และซ่อนลูกศรด้วย จะได้ไม่ชวนให้กด
            onPressed: widget.embedded ? null : () {
              PushPopup(
                  title: 'เลือกบุคลากร',
                  fit: FlexFit.tight,
                  maxHeight: 700,
                  scroll: false,
                  builder: (BuildContext context) {
                    return ChoosePersonnel(
                        onChoose: (personnel) {
                          setState(() => this.personnel = personnel);
                        }
                    );
                  }
              ).showPopup(context);
            },
          )
        ],
      ),
    );
  }
}
