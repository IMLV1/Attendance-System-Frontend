import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:attendance_system/shared/widgets/utils/downloader.dart';
import 'package:attendance_system/shared/widgets/utils/ios_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdfrx/pdfrx.dart';

/// ตัวดูไฟล์แนบเต็มจอ
///
/// 🚩 (2026-08-27) เดิมทั้งหน้าเป็น `OverlayEntry` ที่ประกอบเองจากศูนย์ ซึ่งพา
/// ปัญหามาหลายอย่างพร้อมกัน — ทั้งหมดนี้เห็นด้วยตาบนเว็บแล้ว:
///
/// 1. **รูปไปกองชิดซ้าย** ไม่อยู่กลางจอ — `Column` ที่ห่อรูปเป็นลูกแบบไม่
///    `Positioned` ใน `Stack` ซึ่งจัดชิด topLeft เป็นค่าเริ่มต้น และกว้างเท่าลูก
///    ของตัวเองไม่ใช่เต็มจอ บนจอ 1742px รูปกินแค่ถึง x≈1134 เหลือขวาว่าง 600px
/// 2. **ฉากหลังจางเกิน** (`alpha 0.8`) อ่านหน้าที่อยู่ข้างหลังออกทั้งหน้า
/// 3. **Esc ปิดไม่ได้** และปุ่ม back ของเบราว์เซอร์/Android ก็ปิดไม่ได้ เพราะ
///    overlay ไม่ใช่ route ระบบนำทางจึงไม่รู้จักมัน
/// 4. กดปิดรัวๆ สองที `_controller.dispose()` โดนเรียกซ้ำ → throw
/// 5. `padding` อยู่**ข้างใน** `InteractiveViewer` ขอบเลยซูมตามรูปไปด้วย
///
/// ทำเป็น **route** แทน ได้ปุ่ม back / Esc / focus / การคืนทรัพยากรมาฟรีจาก
/// `Navigator` ทั้งชุด — ของที่เดิมต้องเขียนเองทีละอย่างและเขียนไม่ครบ
///
/// เติมท่ามาตรฐานของตัวอ่านรูปเข้าไปด้วย: แตะสองทีเพื่อซูม, ลากลงเพื่อปิด
/// (ฉากหลังจางลงตามระยะที่ลาก) และยุบปุ่มบันทึก/แชร์/เปิดด้วยแอปอื่นมาไว้ใน
/// เมนูเดียวที่มุมขวาบน — เดิมสองอันแรกอยู่ในเมนูของ**การ์ดไฟล์** ส่วนอันหลัง
/// อยู่ใน**พรีวิว** คนละที่กัน
///
/// API เดิมคงไว้ (`FilePreviewPopup(file: f).showPopup(context)`) จุดเรียกทั้ง
/// 6 ที่จึงไม่ต้องแก้
class FilePreviewPopup {
  const FilePreviewPopup({required this.file});

  final NetworkFile file;

  Future<void> showPopup(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        // โปร่งใสได้ = หน้าข้างล่างยังถูกวาดอยู่ ฉากหลังจึงค่อยๆ จางเข้ามาได้
        opaque: false,
        barrierColor: null,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) => _FilePreviewView(file: file),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
      ),
    );
  }
}

class _FilePreviewView extends StatefulWidget {
  const _FilePreviewView({required this.file});

  final NetworkFile file;

  @override
  State<_FilePreviewView> createState() => _FilePreviewViewState();
}

class _FilePreviewViewState extends State<_FilePreviewView> {
  /// ระยะที่ต้องลากลงก่อนปล่อยแล้วถือว่า "ปิด"
  static const double _dismissThreshold = 120;

  final PdfViewerController _pdfController = PdfViewerController();
  final TransformationController _zoom = TransformationController();

  /// ใช้แปลงพิกัดที่แตะให้เป็นพิกัดในกรอบของ viewer ตอนซูมเข้าหาจุดที่แตะ
  final GlobalKey _viewerKey = GlobalKey();
  final MenuController _menu = MenuController();

  /// ปุ่ม `…` — บน iPad share sheet เป็น popover ที่ต้องชี้มาที่ปุ่มนี้
  final GlobalKey _menuKey = GlobalKey();

  /// ระยะที่นิ้วลากลงอยู่ตอนนี้ — ใช้ทั้งเลื่อนรูปและหรี่ฉากหลัง
  double _dragOffset = 0;

  /// ตำแหน่งที่แตะสองทีล่าสุด (พิกัดจอ) — เก็บไว้เพื่อซูมเข้าหาจุดนั้น
  Offset? _lastTap;

  bool _busy = false;

  bool get _isPdf => widget.file.fileType.toLowerCase() == 'pdf';

  /// PDF เลื่อนอ่านในแนวตั้งอยู่แล้ว ถ้าดักลากลงด้วยจะแย่งท่ากัน
  bool get _canDragToDismiss => !_isPdf;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _zoom.dispose();
    super.dispose();
  }

  /// 🚩 (2026-08-27) ดัก Esc ที่ `HardwareKeyboard` ตรงๆ ไม่ผ่าน `Focus`
  ///
  /// ลอง `Focus(autofocus: true, onKeyEvent: ...)` ก่อนแล้วไม่ทำงาน — ยิง Esc
  /// เข้าไปแล้วพรีวิวยังอยู่ ทางนี้ไม่ขึ้นกับว่าตอนนั้นโฟกัสอยู่ที่ไหน ซึ่งเดาไม่ได้
  /// เพราะในหน้ามีปุ่มกับเมนูที่แย่งโฟกัสกันเอง
  ///
  /// handler มีอายุเท่ากับตัว widget และตอบเฉพาะ Esc จึงไม่ไปกวนหน้าอื่น
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.escape || !mounted) {
      return false;
    }

    // เมนูเปิดอยู่ให้ปิดเมนูก่อน ค่อยปิดพรีวิวในการกดครั้งถัดไป
    if (_menu.isOpen) {
      _menu.close();
    } else {
      Navigator.of(context).pop();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // ฉากหลังทึบเกือบสนิทตามธรรมเนียมตัวอ่านรูป — จางลงตามระยะที่ลากลง เพื่อให้
    // รู้สึกว่ากำลัง "ดึงออก" ไม่ใช่แค่รูปขยับเฉยๆ
    final progress = (_dragOffset.abs() / (_dismissThreshold * 2)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.95 * (1 - progress)),
      body: Stack(
        children: [
          Positioned.fill(
            child: Transform.translate(offset: Offset(0, _dragOffset), child: _content()),
          ),
          _topBar(),
        ],
      ),
    );
  }

  Widget _content() {
    if (_isPdf) return _pdf();

    final viewer = Center(
      child: InteractiveViewer(
        key: _viewerKey,
        transformationController: _zoom,
        minScale: 1,
        maxScale: 10,
        // 🚩 (2026-08-27) ท่า "ลากลงเพื่อปิด" ต้องขี่ callback ของ
        // `InteractiveViewer` เอง ห้ามใช้ `GestureDetector` ครอบข้างนอก
        //
        // ลองแบบครอบข้างนอกก่อนแล้วไม่ทำงานเลย: viewer สร้าง
        // `ScaleGestureRecognizer` ของตัวเองซึ่งชนะใน gesture arena ทุกครั้ง
        // ต่อให้ตอนนั้นยังไม่ได้ซูมและมันไม่ได้เอา pan ไปทำอะไร
        onInteractionUpdate: _canDragToDismiss ? _onInteractionUpdate : null,
        onInteractionEnd: _canDragToDismiss ? _onInteractionEnd : null,
        child: Image.network(
          widget.file.fileUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CupertinoActivityIndicator(color: Colors.white)),
          errorBuilder: (_, _, _) => _error(),
        ),
      ),
    );

    return GestureDetector(
      // แตะสองทีเพื่อสลับซูม — ท่าที่คนคาดหวังจากตัวอ่านรูปทุกตัว
      onDoubleTapDown: (details) => _lastTap = details.globalPosition,
      onDoubleTap: _toggleZoom,
      child: Padding(
        // อยู่**นอก** InteractiveViewer — ไม่งั้นขอบจะซูมตามรูปไปด้วย
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
        child: viewer,
      ),
    );
  }

  Widget _pdf() {
    return PdfViewer.uri(
      Uri.parse(widget.file.fileUrl),
      controller: _pdfController,
      params: PdfViewerParams(
        backgroundColor: Colors.transparent,
        margin: 30,
        scrollPhysics: const BouncingScrollPhysics(),
        // เว้นหัวเท่าของที่บังจริง = safe area + ความสูงแถบปุ่ม ไม่ใช่ตัวเลขที่
        // เคาะด้วยสายตาบนมือถือแล้วเว้นเกินบน iPad
        boundaryMargin: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + kToolbarHeight + 24,
          bottom: 20,
        ),
        loadingBannerBuilder: (_, _, _) =>
            const Center(child: CupertinoActivityIndicator(color: Colors.white)),
        errorBannerBuilder: (_, _, _, _) => _error(),
      ),
    );
  }

  Widget _error() {
    return Center(
      child: Column(
        spacing: 30,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/error.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            width: 50,
            height: 50,
          ),
          const Text(
            'โหลดเอกสารไม่สำเร็จ',
            style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }

  // ── แถบบน ──────────────────────────────────────────────────────────────

  Widget _topBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.transparent],
            stops: [0.2, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),

                // ชื่อไฟล์ยืดตามที่เหลือ ไม่ fix ความกว้างไว้ 200 เหมือนเดิม
                // ซึ่งตัดชื่อภาษาไทยทิ้งตั้งแต่ยังไม่ทันยาว
                Expanded(
                  child: Text(
                    widget.file.fileName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),

                SizedBox(width: 48, child: _actionsButton()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionsButton() {
    if (_busy) {
      return const Center(child: CupertinoActivityIndicator(color: Colors.white));
    }

    return MenuAnchor(
      controller: _menu,
      alignmentOffset: const Offset(0, 6),
      style: IosMenu.menuStyle,
      menuChildren: [
        IosMenu(
          width: 240,
          children: [
            // 🚩 ใช้ไอคอนชุด Material ทั้งเมนู ไม่ใช้ `download.svg` ของแอป
            // เพราะไฟล์นั้นจริงๆ เป็นไอคอน "export" (กล่องมีลูกศรพุ่งออก) ซึ่ง
            // เป็นภาพเดียวกับ `open_in_new` เป๊ะ — พอมาอยู่เมนูเดียวกันจะกลาย
            // เป็นสองบรรทัดที่หน้าตาเหมือนกันแต่ทำคนละเรื่อง
            IosMenuItem(
              iconData: Icons.download_outlined,
              label: 'บันทึกไฟล์',
              onTap: () => _run((d) => d.saveFile(widget.file)),
            ),
            if (Downloader.canShare)
              IosMenuItem(
                iconData: Icons.ios_share,
                label: 'แชร์ไฟล์',
                onTap: () => _run((d) => d.shareFile(
                  widget.file,
                  // ต้องชี้ที่ปุ่ม `…` ไม่ใช่ context ของทั้งหน้า ไม่งั้น
                  // popover บน iPad จะไปโผล่กลางจอห่างจากปุ่มที่กด
                  origin: Downloader.originOf(_menuKey.currentContext!),
                )),
              ),
            // ครึ่งหลังของทาง B3 — พรีวิวยังอยู่ในแอป แต่มีทางออกไปหาแอปของ
            // ระบบสำหรับสิ่งที่ viewer นี้ทำไม่ได้ (พิมพ์ / ค้นคำในเอกสาร /
            // เขียนโน้ตทับ / เซฟเข้า Files)
            IosMenuItem(
              iconData: Icons.open_in_new,
              label: 'เปิดด้วยแอปอื่น',
              onTap: () => _run((d) => d.openExternally(widget.file)),
            ),
          ],
        ),
      ],
      builder: (context, controller, _) => IconButton(
        key: _menuKey,
        icon: const Icon(Icons.more_horiz, color: Colors.white),
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }

  Future<void> _run(Future<void> Function(Downloader) action) async {
    // เมนูอยู่ใน overlay ไม่ใช่ route — ปิดด้วย controller เท่านั้น
    // (เคยเผลอใช้ Navigator.pop() แล้วมันไปเด้ง route ของหน้าออกแทน)
    _menu.close();

    setState(() => _busy = true);
    await action(Downloader(onError: (e) => debugPrint('🟠 จัดการไฟล์ไม่สำเร็จ — $e')));
    if (mounted) setState(() => _busy = false);
  }

  // ── ท่าสัมผัส ──────────────────────────────────────────────────────────

  /// 🚩 ซูม**เข้าหาจุดที่แตะ** ไม่ใช่มุมซ้ายบน
  ///
  /// รอบแรกใช้ `Matrix4.identity()..scale(2.5)` เฉยๆ ซึ่งขยายรอบจุด (0,0) ของรูป
  /// — แตะกลางรูปแล้วภาพกระโดดไปโชว์มุมซ้ายบนแทน ผิดจากที่ทุกแอปทำ
  ///
  /// สูตรที่ทำให้จุด p อยู่กับที่: เลื่อน `-p * (s - 1)` แล้วค่อยขยาย s เท่า
  void _toggleZoom() {
    const scale = 2.5;

    if (_isZoomed) {
      _zoom.value = Matrix4.identity();
      return;
    }

    final box = _viewerKey.currentContext?.findRenderObject();
    final tap = _lastTap;
    if (box is! RenderBox || tap == null) {
      _zoom.value = Matrix4.identity()..scaleByDouble(scale, scale, scale, 1);
      return;
    }

    final local = box.globalToLocal(tap);
    _zoom.value = Matrix4.identity()
      ..translateByDouble(-local.dx * (scale - 1), -local.dy * (scale - 1), 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  bool get _isZoomed => _zoom.value.getMaxScaleOnAxis() > 1.01;

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    // ซูมอยู่ = การลากคือการเลื่อนดูรูป ไม่ใช่การปิด
    // สองนิ้วขึ้นไป = กำลังจะซูม ไม่ใช่จะปิด
    if (_isZoomed || details.pointerCount > 1) return;
    setState(() => _dragOffset += details.focalPointDelta.dy);
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (_isZoomed || _dragOffset == 0) return;

    if (_dragOffset.abs() > _dismissThreshold || details.velocity.pixelsPerSecond.dy.abs() > 700) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _dragOffset = 0);
  }
}
