import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/widgets/utils/role_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ป้ายตำแหน่งเคยล้นกรอบและสูงไม่จำกัด — เทสต์นี้กันทั้งสองอย่าง
///
/// `pumpWidget` จะโยน exception เองถ้ามีอะไรล้นกรอบใน debug mode
/// เคสที่กว้างไม่พอจึงเป็นตัวจับ regression ของอาการล้นไปในตัว
void main() {
  List<Role> rolesOf(List<String> names) => [
        for (var i = 0; i < names.length; i++)
          Role(id: '$i', name: names[i], color: const Color(0xFF2C2C2C)),
      ];

  Future<void> pump(WidgetTester tester, List<Role> roles, double width,
      {int maxLines = 2}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: RoleChips(roles: roles, maxLines: maxLines),
            ),
          ),
        ),
      ),
    );
  }

  /// นับป้ายจริงๆ ที่วาดออกมา (ไม่รวมป้าย '...')
  int chipCount(WidgetTester tester, List<Role> roles) =>
      roles.where((r) => find.text(r.name).evaluate().isNotEmpty).length;

  testWidgets('ที่พอ — แสดงครบ ไม่มีป้าย ...', (tester) async {
    final roles = rolesOf(['HR', 'Admin']);
    await pump(tester, roles, 400);

    expect(chipCount(tester, roles), 2);
    expect(find.text('...'), findsNothing);
  });

  testWidgets('ตำแหน่งเยอะ — ตัดที่ 2 บรรทัดแล้วขึ้น ...', (tester) async {
    final roles = rolesOf([
      'ผู้ดูแลระบบ',
      'ฝ่ายบุคคล',
      'หัวหน้าภาค',
      'รองคณบดี',
      'คณบดี',
      'อาจารย์ภาคคอม',
      'กรรมการหลักสูตร',
      'ผู้ช่วยคณบดีฝ่ายวิชาการ',
    ]);
    await pump(tester, roles, 200);

    expect(find.text('...'), findsOneWidget);
    expect(chipCount(tester, roles), lessThan(roles.length));
  });

  testWidgets('maxLines 2 สูงไม่เกินสองแถว', (tester) async {
    final roles = rolesOf(List.generate(20, (i) => 'ตำแหน่งที่ $i'));

    await pump(tester, roles, 200, maxLines: 1);
    final oneLine = tester.getSize(find.byType(RoleChips)).height;

    await pump(tester, roles, 200, maxLines: 2);
    final twoLines = tester.getSize(find.byType(RoleChips)).height;

    expect(twoLines, greaterThan(oneLine));
    // สองบรรทัด = สูงกว่าหนึ่งบรรทัดไม่ถึงเท่าตัวครึ่ง (บวก runSpacing)
    expect(twoLines, lessThan(oneLine * 2 + 10));
  });

  testWidgets('ชื่อตำแหน่งเดียวที่ยาวกว่าพื้นที่ — ไม่ล้น', (tester) async {
    // เคสนี้คืออาการเดิมเป๊ะ: ป้ายเดียวกว้างกว่าคอลัมน์ที่เหลือ
    final roles =
        rolesOf(['ผู้ช่วยคณบดีฝ่ายกิจการนิสิตและกิจการพิเศษประจำวิทยาเขต']);
    await pump(tester, roles, 90);

    expect(find.byType(RoleChips), findsOneWidget);
  });

  testWidgets('ไม่มีตำแหน่ง — ไม่กินที่', (tester) async {
    await pump(tester, const [], 200);
    expect(tester.getSize(find.byType(RoleChips)).height, 0);
  });
}
