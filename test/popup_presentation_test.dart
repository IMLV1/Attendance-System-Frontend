import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/popup_surface.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// (Phase 3) `PopupSurface` เปลี่ยน popup จาก bottom sheet ตายตัว เป็นแผ่นเลื่อน
/// บนมือถือ / กล่องกลางจอบนแท็บเล็ตขึ้นไป — ตรรกะเคยตรวจแต่ในโค้ด ยังไม่เคยมี
/// อะไรกันไม่ให้พังย้อนกลับ
///
/// เทสนี้จับสองอย่าง:
///   1. เลือกเปลือกถูกตามขนาดจอ (compact -> sheet, medium/expanded -> dialog)
///   2. เนื้อหาไม่ล้นกรอบในทุกขนาดจอ — overflow ใน widget test จะโยน exception
///      ซึ่งเป็นความเสี่ยงหลักของ wizard ที่คุมความสูงเองผ่าน AnimatedContainer

/// ขนาดจอจริงที่ใช้ทดสอบ (logical pixels)
const _phone = Size(390, 844); // iPhone 17 Pro       -> compact
const _tabletPortrait = Size(1032, 1376); // iPad Pro 13 แนวตั้ง -> medium
const _tabletLandscape = Size(1376, 1032); // iPad Pro 13 แนวนอน -> expanded
const _desktop = Size(1680, 965); // Chrome desktop      -> expanded

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: child));
}

/// ปุ่มที่กดแล้วเปิด popup — ต้องมี BuildContext ที่อยู่ใต้ Navigator จริง
Widget _opener(void Function(BuildContext context) open) => Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => open(context),
            child: const Text('เปิด'),
          ),
        ),
      ),
    );

void main() {
  group('เลือกเปลือกตามขนาดจอ', () {
    for (final (name, size, expected) in [
      ('มือถือ -> แผ่นเลื่อน', _phone, PopupPresentation.sheet),
      ('iPad แนวตั้ง -> กล่องกลางจอ', _tabletPortrait, PopupPresentation.dialog),
      ('iPad แนวนอน -> กล่องกลางจอ', _tabletLandscape, PopupPresentation.dialog),
      ('desktop -> กล่องกลางจอ', _desktop, PopupPresentation.dialog),
    ]) {
      testWidgets(name, (tester) async {
        late PopupPresentation actual;
        await _pumpAt(
          tester,
          size,
          Builder(builder: (context) {
            actual = PopupSurface.presentationOf(context);
            return const SizedBox();
          }),
        );
        expect(actual, expected);
      });
    }
  });

  group('PushPopup', () {
    for (final (name, size, isDialog) in [
      ('มือถือได้แผ่นเลื่อน', _phone, false),
      ('iPad แนวตั้งได้กล่องกลางจอ', _tabletPortrait, true),
      ('desktop ได้กล่องกลางจอ', _desktop, true),
    ]) {
      testWidgets('$name — และไม่ล้นกรอบ', (tester) async {
        await _pumpAt(
          tester,
          size,
          _opener((context) => PushPopup(
                title: 'หัวข้อทดสอบ',
                buttonLabel: 'บันทึก',
                maxHeight: 650,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    8,
                    (i) => ListTile(title: Text('รายการที่ $i')),
                  ),
                ),
              ).showPopup(context)),
        );

        await tester.tap(find.text('เปิด'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(Dialog), isDialog ? findsOneWidget : findsNothing);
        expect(find.text('หัวข้อทดสอบ'), findsOneWidget);
      });
    }
  });

  group('DynamicPushPopup (wizard) — ตัวที่เสี่ยงสุด', () {
    for (final (name, size, isDialog) in [
      ('มือถือ', _phone, false),
      ('iPad แนวตั้ง', _tabletPortrait, true),
      ('iPad แนวนอน', _tabletLandscape, true),
      ('desktop', _desktop, true),
    ]) {
      testWidgets('$name — เปิดได้และไม่ล้นกรอบ', (tester) async {
        await _pumpAt(
          tester,
          size,
          _opener((context) => DynamicPushPopup(
                initialConfig: PopupConfig(
                  title: 'ขั้นตอนที่ 1',
                  buttonLabel: 'ถัดไป',
                  maxHeight: 600,
                ),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    6,
                    (i) => ListTile(title: Text('บรรทัด $i')),
                  ),
                ),
              ).showPopup(context)),
        );

        await tester.tap(find.text('เปิด'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(Dialog), isDialog ? findsOneWidget : findsNothing);
        expect(find.text('ขั้นตอนที่ 1'), findsOneWidget);
      });
    }
  });
}
