import 'package:attendance_system/core/utils/navigation_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sealed_countries/sealed_countries.dart';

import 'app/app.dart';
import 'core/utils/responsive.dart';
import 'core/auth/auth_state.dart';
import 'service_locator.dart';
import 'services/notification/notification_provider.dart';

List<String> cachedThaiNationalities = [];

void prepareNationalities() {
  // Doing this while the app is loading or idle
  // means the work is already done when the popup opens.
  cachedThaiNationalities = WorldCountry.list.map((country) {
    return country.translations.firstWhere(
          (t) => t.language == const LangTha(),
      orElse: () => country.name,
    ).common;
  }).toList()..sort();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th_TH', null);
  await dotenv.load(fileName: '.env');
  await setupServiceLocator();
  await getIt<AuthState>().init();
  prepareNationalities();

  usePathUrlStrategy(); // see https://pub.dev/packages/url_strategy
  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthState>.value(
          value: getIt<AuthState>(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..fetchNotifications(),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationGuard(),
        ),
      ],
      // 🚩 (2026-08-25) เดิมมี `MaterialApp` ครอบ `App()` อีกชั้น ทั้งที่ `App`
      // เองก็เป็น `MaterialApp.router` อยู่แล้ว — MaterialApp ซ้อนกันแปลว่ามี
      // Navigator สองตัว และตัวนอกเป็นคนรับ initial route จาก engine
      // บน web จึงกิน path ที่ผู้ใช้เปิดมาทิ้ง (คอนโซลขึ้น "Could not navigate
      // to initial route") go_router ไม่เคยเห็น URL จริง ตกไปใช้
      // `initialLocation` ทุกครั้ง = เปิดลิงก์ตรงหรือกด F5 ก็เด้งกลับ /check-in
      //
      // ชั้นนอกมีไว้แค่ครอบ GestureDetector ปิดคีย์บอร์ด ย้ายไปเป็น `builder`
      // ของ MaterialApp.router ใน app.dart แทน ได้ผลเหมือนกันแต่ไม่ซ้อน
      child: const App(),
    ),
  );

  _lockPortraitOnPhonesOnly();
}

/// ล็อกแนวตั้ง **เฉพาะมือถือ** — แท็บเล็ตหมุนได้อิสระ
///
/// 🚩 (2026-08-24) เดิมเรียก `setPreferredOrientations([portraitUp])` ก่อน
/// `runApp()` แบบไม่แยกเครื่อง ซึ่งขัดกับงาน responsive ทั้งก้อน: iPad หมุน
/// แนวนอนไม่ได้เลย จึงเข้าโหมด `expanded` (sidebar + layout สองคอลัมน์) ไม่ได้
/// ทั้งที่ `Info.plist` อนุญาตทุกแนวบน iPad อยู่แล้ว
///
/// บนมือถือยังล็อกเหมือนเดิม เพราะ layout ของ compact ถูกจูนมาให้ทุก component
/// พอดีหน้าเดียวในแนวตั้ง (ดู `checkin_page.dart`) หมุนแนวนอนแล้วเตี้ยเกินใช้
///
/// ต้องรอหลังเฟรมแรกถึงจะรู้ขนาดจอจริง — ก่อนหน้านั้น `physicalSize` ยังเป็น
/// ศูนย์อยู่ ถ้าเช็คตอน `main()` จะได้ค่าผิดแล้วไปล็อกแท็บเล็ตด้วย
/// (`setPreferredOrientations` ไม่มีผลบน web/desktop อยู่แล้ว จึงไม่ต้องกันเพิ่ม)
void _lockPortraitOnPhonesOnly() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) return;

    final shortestSide =
        (view.physicalSize / view.devicePixelRatio).shortestSide;

    // ใช้เกณฑ์เดียวกับที่ `Responsive` ใช้แบ่งมือถือ/แท็บเล็ต จะได้ไม่หลุดกัน
    if (shortestSide >= Responsive.mobileMax) return;

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  });
}
