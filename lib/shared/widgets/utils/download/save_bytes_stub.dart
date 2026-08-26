import 'dart:typed_data';

/// ตัวแทนบนแพลตฟอร์มที่ไม่ใช่เว็บ — ไม่ถูกเรียกจริง เพราะ `Downloader` แยกทาง
/// ด้วย `kIsWeb` ก่อนอยู่แล้ว มีไว้ให้ conditional import มีของให้ resolve
Future<void> saveBytesToDevice(Uint8List bytes, String fileName) {
  throw UnsupportedError('saveBytesToDevice ใช้ได้เฉพาะบนเว็บ');
}
