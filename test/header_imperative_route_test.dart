// 🚩 (2026-08-24) กันอาการ "จอค้าง กดอะไรไม่ได้เลย" กลับมาอีก
//
// หน้าจำนวนหนึ่งไม่ได้อยู่ใน routes.dart แต่ถูก push ด้วย MaterialPageRoute ตรงๆ
// (หน้าย่อยทั้ง 5 ของ /personnel-info, UserInfo, CreateUser, AssignRole, EditRole,
// ConfigLeave, MaxLeave, SetMaxLeave, LeaveApprovalDetail, OverallInfo)
// หน้าพวกนี้ไม่มี GoRouterState อยู่เหนือ context ถ้า Header ไปเรียก
// GoRouterState.of() ตรงๆ มันจะ throw ทั้งหน้าจึงสร้างไม่ขึ้น เหลือหน้าเปล่า
// ที่ไม่มีปุ่ม back ทับหน้าเดิมอยู่ = กดอะไรไม่ได้เลย
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _PageWithSubHeader extends StatelessWidget {
  const _PageWithSubHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(context, title: title),
      content: const SizedBox.shrink(),
    );
  }
}

void main() {
  testWidgets('subHeader ใช้ได้กับหน้าที่ push ด้วย MaterialPageRoute (ไม่ผ่าน go_router)',
      (tester) async {
    // ขนาดมือถือ — ไม่ให้เข้าโหมด sidebar ซึ่ง header จะไปเรียก NotificationProvider
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/personnel-info',
      routes: [
        GoRoute(
          path: '/personnel-info',
          builder: (_, _) => const _PageWithSubHeader(title: 'ข้อมูลบุคลากรในองค์กร'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // push หน้าลูกแบบเดียวกับที่ personnel_info.dart ทำ
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.push(MaterialPageRoute<void>(
      builder: (_) => const _PageWithSubHeader(title: 'ข้อมูลส่วนตัว'),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('ข้อมูลส่วนตัว'), findsOneWidget);
    // หน้าที่ push มาเองต้องมีปุ่ม back เสมอ ไม่งั้นถอยกลับไม่ได้
    expect(find.byType(IconButton), findsWidgets);
  });

  _mainLoopCase();
}

// 🚩 อาการจริงที่เจอบนเครื่อง (24 ส.ค.): หน้าที่ push เองไม่ได้แค่ throw แต่
// rebuild วนไม่จบกิน CPU 100% — เพราะ GoRouterState.of() ไล่ขึ้นไปตาม Navigator
// แล้วไปลงทะเบียน dependency บน context ของ Navigator (ไม่ใช่ของ widget ที่กำลัง
// build อยู่) พอ registry แจ้งเปลี่ยน Navigator ก็ rebuild ทั้งสาย -> หน้าเราถูก
// build ใหม่ -> ลงทะเบียนอีก -> วนไม่จบ
//
// เคสนี้ต้องมี route ของ go_router เป็นชั้นแม่ (เหมือน ShellRoute จริงในแอป)
// ไม่งั้น GoRouterState.of() จะ throw ตั้งแต่รอบแรกแล้วไม่ทันเข้าลูป
void _mainLoopCase() {
  testWidgets('หน้าที่ push เองต้องไม่ rebuild วนไม่จบ (มี route แม่เป็น go_router)',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final shellKey = GlobalKey<NavigatorState>();
    final router = GoRouter(
      initialLocation: '/personnel-info',
      routes: [
        ShellRoute(
          navigatorKey: shellKey,
          builder: (_, _, child) => child,
          routes: [
            GoRoute(
              path: '/personnel-info',
              builder: (_, _) => const _PageWithSubHeader(title: 'ข้อมูลบุคลากรในองค์กร'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    shellKey.currentState!.push(MaterialPageRoute<void>(
      builder: (_) => const _PageWithSubHeader(title: 'การลางาน'),
    ));

    // ถ้า rebuild วนไม่จบ pumpAndSettle จะ timeout ตรงนี้
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('การลางาน'), findsOneWidget);
  });
}
