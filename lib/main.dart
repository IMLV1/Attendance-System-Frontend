import 'dart:async';

import 'package:attendance_system/core/utils/navigation_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // 🚩 (2026-08-26) คู่ preserve/remove นี้จำเป็นเพราะ **web** โดยเฉพาะ
  //
  // `flutter_native_splash:create` เขียน `<picture id="splash">` กับฟังก์ชัน
  // `removeSplashFromWeb()` ลงใน web/index.html ให้ แต่**ไม่มีใครเรียกฟังก์ชัน
  // นั้นเลย** (สมัยที่ยังโหลดผ่าน flutter.js มีตัวเรียกให้ พอย้ายมาใช้
  // flutter_bootstrap.js ก็ไม่มีแล้ว) ถ้าไม่ต่อสายเอง รูป splash จะค้างอยู่ใน
  // DOM ตลอดอายุหน้าเว็บ และ `body` ก็ยังทาสีพื้นทับอยู่
  //
  // `remove()` ของ package เป็นตัวที่ไปเรียก `removeSplashFromWeb()` ให้
  // ส่วนบน iOS/Android มันแทบไม่ทำอะไร เพราะ LaunchScreen ของ OS ถูกถอดตอน
  // engine วาดเฟรมแรกอยู่แล้ว — และเป็นสิ่งที่เราต้องการพอดี: ส่งไม้ต่อให้หน้า
  // `/splash` ของ Flutter ที่หน้าตาเหมือนกันเป๊ะทันที ไม่ต้องหน่วงไว้
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await initializeDateFormatting('th_TH', null);
  await dotenv.load(fileName: '.env');
  await setupServiceLocator();
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

  // 🚩 (2026-08-26) เดิมบรรทัดนี้เป็น `await getIt<AuthState>().init();` อยู่
  // **ก่อน** `runApp()` แปลว่าตั้งแต่กดไอคอนแอปจนถึงเฟรมแรกของ Flutter ผู้ใช้
  // มองจอเปล่าๆ อยู่ตลอดเวลาที่รอ token + 4 API — และ route `/splash` ที่เขียน
  // ไว้แล้วก็ไม่มีวันถูกเห็น เพราะกว่าจะวาดได้ `status` ก็พ้น `unknown` ไปแล้ว
  //
  // ย้ายมาไว้หลัง `runApp()` และ **ไม่ await** — เฟรมแรกขึ้นทันทีโดย `status`
  // ยังเป็น `unknown` redirect ใน routes.dart จึงพาไป `/splash` ตามที่ออกแบบไว้
  // พอ `init()` เสร็จมันเรียก `notifyListeners()` ซึ่ง `refreshListenable` ของ
  // GoRouter ฟังอยู่ → redirect ทำงานอีกรอบ → พาไปหน้าที่ผู้ใช้ขอมาจริงๆ
  // (`_pendingLocation`) หรือ `/login` โดยอัตโนมัติ ไม่ต้องเดินสายเพิ่มเลย
  //
  // ใช้ `unawaited` ไม่ใช่ปล่อยลอยๆ เพื่อบอกทั้งคนอ่านและ lint ว่าตั้งใจไม่รอ
  // error ที่หลุดออกมาจาก init() จะไปโผล่เป็น unhandled error ของ zone เหมือน
  // ตอนที่ยัง await อยู่ก่อน runApp
  // เฟรมแรกของ Flutter (= หน้า /splash) ถูกกำหนดให้วาดแล้ว ปลด splash ชั้น
  // native/web ทิ้งได้ ผู้ใช้จะไม่เห็นรอยต่อเพราะสองชั้นวาดโลโก้ตัวเดียวกัน
  // บนพื้นสีเดียวกัน
  FlutterNativeSplash.remove();

  // ผูก lifecycle ที่นี่ (ไม่ใช่ใน init()) เพราะต้องมั่นใจว่า binding ถูกสร้างแล้ว
  // — resume แต่ละครั้งจะโหลดสิทธิ์ของผู้ใช้ใหม่ ดู AuthState.reloadUser()
  getIt<AuthState>().observeAppLifecycle();
  unawaited(getIt<AuthState>().init());

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
