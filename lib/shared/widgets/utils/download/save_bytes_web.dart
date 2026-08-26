import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// สั่งให้เบราว์เซอร์ "ดาวน์โหลด" ไฟล์จริงๆ ผ่าน blob + `<a download>`
///
/// 🚩 (2026-08-26) เดิมเว็บใช้ `launchUrl(fileUrl)` ซึ่งไม่ใช่การดาวน์โหลด —
/// มันแค่เปิดแท็บใหม่ ไฟล์ที่เบราว์เซอร์แสดงได้ (รูป/PDF) ก็โผล่มาให้ดูเฉยๆ
/// ผู้ใช้ต้องกดบันทึกเองอีกที ส่วนไฟล์ประเภทอื่นได้แท็บว่างหรือโดน popup blocker
///
/// จะแปะ `download` ลงบน `<a href="{fileUrl}">` ตรงๆ ก็ไม่ได้ เพราะ attribute
/// นั้น**ถูกเบราว์เซอร์เมิน** เมื่อ href ข้าม origin — และของเราข้ามแน่นอน
/// (แอปอยู่ :5050 ไฟล์อยู่ backend :3000) จึงต้องดึง bytes มาเองก่อนแล้วทำ
/// blob URL ที่เป็น same-origin ค่อยสั่งดาวน์โหลด
///
/// ต้อง revoke object URL ทิ้ง ไม่งั้น blob ค้างในหน่วยความจำจนกว่าจะปิดแท็บ
void saveBytesToDeviceSync(Uint8List bytes, String fileName) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );
  final url = web.URL.createObjectURL(blob);

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName
    ..style.display = 'none';

  web.document.body!.appendChild(anchor);
  anchor.click();
  anchor.remove();

  web.URL.revokeObjectURL(url);
}

Future<void> saveBytesToDevice(Uint8List bytes, String fileName) async {
  saveBytesToDeviceSync(bytes, fileName);
}
