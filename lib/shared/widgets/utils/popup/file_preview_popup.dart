import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdfrx/pdfrx.dart';

class FilePreviewPopup {

  final NetworkFile file;

  FilePreviewPopup({required this.file});

  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _opacity;
  PdfViewerController pdfViewerController = PdfViewerController();

  void showPopup(BuildContext context) {
    _controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 250),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    print(Theme.of(context).textTheme?.bodyMedium?.decoration ?? '');

    final double topGap = MediaQuery.of(context).padding.top + 3 * kToolbarHeight;

    _overlayEntry = OverlayEntry(
      builder: (context) => FadeTransition(
        opacity: _opacity,
        child: Stack(
          children: [
            // 🔥 Black overlay
            Positioned.fill(
              child: GestureDetector(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ),

            (file.fileType.toLowerCase() == 'pdf') ?
            PdfViewer.uri(
              Uri.parse(file.fileUrl),
              controller: pdfViewerController,
              params: PdfViewerParams(
                backgroundColor: Colors.transparent, // โปร่งใสได้จริงๆ
                margin: 30, // ระยะห่างระหว่างหน้ากระดาษ (Gap)
                scrollPhysics: BouncingScrollPhysics(),
                boundaryMargin: EdgeInsets.only(bottom: 20, top: topGap),

                loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
                  return Center(
                    child: CupertinoActivityIndicator(color: Colors.white),
                  );
                },

                // 3. หน้าตาตอนโหลดไฟล์พังหรือ Error (Custom Error)
                errorBannerBuilder: (context, error, stackTrace, documentRef) {
                  return Center(
                      child: Column(
                        spacing: 30,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images/error.svg',
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            width: 50,
                            height: 50,
                          ),
                          Text(
                            'โหลดเอกสารไม่สำเร็จ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                decoration: TextDecoration.none
                            ),
                          ),
                        ],
                      )
                  );
                },
              ),
            ) :
            Column(
              children: [
                Expanded(
                  child: Image.network(
                    file.fileUrl,
                    fit: BoxFit.contain,

                    // ใช้ loadingBuilder ในการดักจับสถานะการโหลด
                    loadingBuilder: (context, child, loadingProgress) {
                      // ถ้า loadingProgress เป็น null แปลว่า "โหลดรูปภาพเสร็จสมบูรณ์ 100% แล้ว"
                      if (loadingProgress == null) {
                        // ค่อยคืนค่า InteractiveViewer ที่หุ้มรูปภาพ (child) กลับไป
                        return InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 10.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                            child: child, // child ตัวนี้คือรูปภาพตัวจริงที่ Flutter เรนเดอร์เสร็จแล้ว
                          ),
                        );
                      }

                      // ถ้ารูปยังโหลดไม่เสร็จ ให้คืนค่าหน้าโหลดดิง (ซึ่งไม่มี InteractiveViewer หุ้มอยู่ เลยซูมไม่ได้)
                      return const Center(
                        child: CupertinoActivityIndicator(color: Colors.white),
                      );
                    },

                    // ส่วนของ errorBuilder ก็จะไม่มี InteractiveViewer หุ้มเช่นกัน ทำให้ซูมตอน Error ไม่ได้
                    errorBuilder: (context, error, stackTrace) {
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
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: TextDecoration.none
                                ),
                              ),
                            ],
                          )
                      );
                    },
                  )
                )
              ],
            ),

            Positioned(
              top: 0,   // ล็อกติดขอบบน
              left: 0,  // ล็อกติดขอบซ้าย
              right: 0, // ล็อกติดขอบขวา
              child: Container(
                // วาด Gradient ที่ Container แทน
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,       // ดำสุดขอบบน
                      Colors.transparent, // ค่อยๆ ใสลงมา
                    ],
                    stops: [0.2, 1.0],
                  ),
                ),
                // เอา AppBar มาใส่ข้างใน Container
                child: SafeArea( // ใส่ SafeArea เพื่อไม่ให้ AppBar ไปซ้อนทับรอยบากมือถือ
                  child: AppBar(
                    toolbarHeight: kToolbarHeight,
                    backgroundColor: Colors.transparent, // ให้ AppBar ใสทะลุเห็นสี Container
                    elevation: 0,
                  ),
                ),
              ),
            ),

            Theme(
              data: Theme.of(context),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [

                    SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(50), // 👈 มุมโค้ง
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  file.fileName,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 17,
                                      decoration: TextDecoration.none,
                                      color: Colors.grey.shade300,
                                      fontWeight: FontWeight.normal
                                  ),
                                )
                            ),
                          ],
                        )
                    ),

                    Positioned(
                      left: 10,
                      child: Material(
                        color: Colors.transparent, // ทำให้พื้นหลังโปร่งใส
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: hidePopup, // กดแล้วปิด Overlay
                        ),
                      ),
                    ),
                  ],
                )
              )
            )
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward(); // 🔥 Fade in
  }

  Future<void> hidePopup() async {
    await _controller.reverse(); // 🔥 Fade out ก่อน
    _overlayEntry?.remove();
    _overlayEntry = null;
    _controller.dispose();
  }
}