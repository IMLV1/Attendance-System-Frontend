import 'package:flutter/widgets.dart';

/// นับว่ามี route ถูก push บน **root navigator** อยู่กี่ชั้น
///
/// 🚩 (2026-08-27) ใช้บอก HtmlElementView ว่าตอนนี้มี popup บังอยู่หรือเปล่า
///
/// DOM element อยู่ชั้นเหนือ canvas ของ Flutter เสมอ popup ที่ Flutter วาดจึงทับ
/// มันไม่ได้ — แตะตรงตำแหน่งปุ่มทั้งที่ popup เปิดอยู่ ตัว element จะรับ event ไป
/// (เจอจริงกับปุ่มแนบไฟล์: เมนูเลือกไฟล์เด้งทะลุปฏิทินขึ้นมา)
///
/// ใช้ `ModalRoute.isCurrentOf` ตรงๆ ไม่ได้ เพราะ popup ทั้งแอปเปิดด้วย
/// `useRootNavigator: true` ไปอยู่คนละ navigator กับหน้า — ฝั่งหน้าจึงยังเห็น
/// ตัวเองเป็น route บนสุดของ navigator ตัวเอง
class RootOverlayTracker extends NavigatorObserver {

  /// route บนสุดของ root navigator ตอนนี้
  ///
  /// เก็บเป็น "ตัว route" ไม่ใช่จำนวนชั้น เพราะการนับชั้นต้องพึ่งลำดับระหว่าง
  /// `didPush` กับตอนที่ widget build ซึ่งไม่การันตี — widget อาจ build ก่อน
  /// observer ทัน แล้วจำชั้นผิดจนซ่อนตัวเองทิ้งตั้งแต่แรก (เจอมาแล้ว)
  ///
  /// เทียบกับ `ModalRoute.of(context)` ของแต่ละตัวแทน: ถ้า route ของตัวเองไม่ใช่
  /// ตัวบนสุด แปลว่ามีอะไรทับอยู่ วิธีนี้ใช้ได้กับทั้ง element ที่อยู่ในหน้า
  /// และที่อยู่ใน popup เอง
  static final ValueNotifier<Route<dynamic>?> topRoute = ValueNotifier(null);

  /// route ที่อยู่บนสุดตอน widget ถูกสร้าง ถูกอะไรทับไปแล้วหรือยัง
  ///
  /// ไม่ใช้ `ModalRoute.of(context)` เทียบ เพราะ go_router ใช้ ShellRoute ซึ่งมี
  /// Navigator ซ้อนอยู่ — route ของหน้าเป็นของ navigator ตัวใน ส่วน observer
  /// เกาะอยู่กับ root ทั้งสองตัวจึงไม่มีวันเท่ากัน (ลองแล้ว element หายหมด)
  ///
  /// จำ "route บนสุดตอนที่ตัวเองโผล่" แทน แล้วถือว่าถูกทับเมื่อค่าปัจจุบัน
  /// ไม่ใช่ตัวนั้นแล้ว
  static bool isCoveredSince(Route<dynamic>? seenAtMount) {
    final top = topRoute.value;
    if (top == null) return false;
    return top != seenAtMount;
  }

  void _set(Route<dynamic>? route) => topRoute.value = route;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(previousRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _set(newRoute);
}
