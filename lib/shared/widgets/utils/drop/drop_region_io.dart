import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

/// ฝั่ง native ใช้ `desktop_drop` ตรงๆ — โค้ดฝั่ง macOS/Windows/Linux ของมันเป็น
/// native จริง ไม่ใช่ shim เหมือนฝั่งเว็บ (ดูเหตุผลที่เว็บต้องเขียนเองใน
/// drop_region_web.dart)
Widget buildDropRegion({
  required Widget child,
  required void Function(bool hovering) onHover,
  required void Function(List<PlatformFile> files) onFiles,
}) {
  return _DesktopDropRegion(
    onHover: onHover,
    onFiles: onFiles,
    child: child,
  );
}

class _DesktopDropRegion extends StatelessWidget {

  const _DesktopDropRegion({
    required this.child,
    required this.onHover,
    required this.onFiles,
  });

  final Widget child;
  final void Function(bool hovering) onHover;
  final void Function(List<PlatformFile> files) onFiles;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => onHover(true),
      onDragExited: (_) => onHover(false),
      onDragDone: (details) async {
        onHover(false);

        final picked = <PlatformFile>[];
        for (final item in details.files) {
          // โฟลเดอร์ลากมาวางได้เหมือนกัน แต่แนบเป็นไฟล์แนบไม่ได้ — ข้ามเงียบๆ
          if (item is DropItemDirectory) continue;

          final bytes = await item.readAsBytes();
          picked.add(PlatformFile(
            name: item.name,
            size: bytes.length,
            path: item.path,
            bytes: bytes,
          ));
        }
        if (picked.isNotEmpty) onFiles(picked);
      },
      child: child,
    );
  }
}
