import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import 'package:attendance_system/shared/theme/app_theme.dart';
import 'package:attendance_system/shared/widgets/utils/popup/popup_surface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'dynamic_popup_config.dart'; // ระบุ path ไฟล์ config ที่เพิ่งสร้าง

class DynamicPushPopup {
  final PopupConfig initialConfig;
  final Widget Function(BuildContext context) builder;

  DynamicPushPopup({
    required this.initialConfig,
    required this.builder,
  });

  void showPopup(BuildContext context) {
    final GlobalKey<NavigatorState> nestedNavKey = GlobalKey<NavigatorState>();

    // เก็บสถานะ Config ปัจจุบัน
    PopupConfig currentConfig = initialConfig;

    // ความสูงจริงของเนื้อหาหน้าปัจจุบัน (โหมดกล่องกลางจอเท่านั้น)
    //
    // 🚩 (2026-08-24) `Navigator` ที่ฝังอยู่ข้างล่างวางตัวเป็น `constraints.biggest`
    // เสมอ (ผ่าน `Overlay` → `_RenderTheatre`) แปลว่าต่อให้ห่อด้วย `Flexible` แบบ
    // `loose` มันก็ยังกินความสูงเต็มเพดานอยู่ดี — วิธีที่ใช้กับ `PushPopup` /
    // `ServicePopup` (สลับ tight เป็น loose) จึงใช้กับตัวนี้ไม่ได้
    //
    // ทางออกคือวัดความสูงเนื้อหาจริงแล้วบอกกล่องให้เท่านั้น ซึ่งเข้ากับดีไซน์เดิม
    // ที่มี `AnimatedContainer` ไล่ความสูงตาม `currentConfig` อยู่แล้ว
    // (บนแผ่นเลื่อนไม่ต้องทำ เพราะมันยึดขอบล่างอยู่แล้ว สูงเต็มก็ดูปกติ)
    double? contentHeight;

    // 🚩 (2026-08-24) ย้ายเปลือกไปให้ PopupSurface ตัดสินตามขนาดจอ
    // (ดูเหตุผลใน popup_surface.dart) — แต่ความสูงยังคุมจากในนี้เหมือนเดิม
    // เพราะ wizard เปลี่ยนความสูงรายหน้าผ่าน currentConfig และต้องอาศัย
    // AnimatedContainer ไล่ความสูงตาม ซึ่งเป็นค่าที่เปลี่ยนหลัง show() ไปแล้ว
    // จึงส่ง maxHeight: infinity ให้ surface คุมแค่เพดานเทียบสัดส่วนจอ
    PopupSurface.show(
      context: context,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // วัดความสูงเนื้อหาได้เฉพาะหน้าที่หดได้จริง คือหน้าที่เปิด `scroll`
            // ไว้ — เนื้อหาจะถูกวางใน `SingleChildScrollView` ซึ่งให้ความสูงแบบ
            // ไม่จำกัด ตัววัดจึงได้ขนาดตามเนื้อหาจริง
            //
            // ส่วนหน้าที่ปิด `scroll` (เช่น `AttendanceDetailPopup` ที่ใช้
            // `Stack` + `Positioned.fill` เพื่อตรึงแถบปุ่มไว้ขอบล่าง) ตั้งใจให้
            // เต็มความสูงอยู่แล้ว ไม่มีความสูงตามธรรมชาติให้วัด — ปล่อยไว้ตามเดิม
            final measurable =
                PopupSurface.presentationOf(context) == PopupPresentation.dialog &&
                    currentConfig.scroll;
            return PopupProvider(
                config: currentConfig,
                setConfig: (PopupConfig newConfig) {
                  setState(() {
                    currentConfig = newConfig; // รีเฟรชกรอบ Popup ใหม่
                  });
                },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350), // 👈 ตั้งความเร็วตอนเลื่อนความสูง
                    curve: Curves.easeOutCubic,
                    constraints: BoxConstraints(
                      minHeight: currentConfig.minHeight,
                      maxHeight: currentConfig.maxHeight == double.infinity
                          ? MediaQuery.of(context).size.height * 0.9
                          : currentConfig.maxHeight,
                    ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 15,
                              children: [
                                Column(
                                    spacing: 15,
                                    children: [
                                      Column(
                                        spacing: 1,
                                        children: [
                                          Stack(
                                            children: [
                                              // 1. ปุ่ม Back
                                              if (currentConfig.backButton)
                                                Align(
                                                  alignment: Alignment.bottomLeft,
                                                  child: Transform.translate(
                                                    offset: const Offset(-5, 0),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                                        minimumSize: Size.zero,
                                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        backgroundColor: Colors.transparent,
                                                        shadowColor: Colors.transparent,
                                                        overlayColor: Colors.transparent,
                                                      ),
                                                      onPressed: () {
                                                        // ถอยหน้าย่อยก่อน ถ้าหมดแล้วค่อยปิด Popup
                                                        if (nestedNavKey.currentState?.canPop() ?? false) {
                                                          nestedNavKey.currentState?.pop();
                                                        } else {
                                                          Navigator.of(bottomSheetContext).pop();
                                                        }
                                                      },
                                                      child: SvgPicture.asset(
                                                        'assets/images/back_button.svg',
                                                        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                              // 2. Title
                                              Align(
                                                alignment: Alignment.bottomCenter,
                                                child: Text(
                                                  currentConfig.title,
                                                  style: TextStyle(
                                                    decoration: TextDecoration.none,
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                    fontFamily: AppTheme.fontFamily,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                ),
                                              ),

                                              // 3. ปุ่ม Action (ขวาบน) + สถานะ Loading
                                              if (currentConfig.buttonLabel.isNotEmpty)
                                                Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: currentConfig.isLoading
                                                      ? const Padding(
                                                    padding: EdgeInsets.only(right: 10),
                                                    child: CupertinoActivityIndicator(),
                                                  )
                                                      : TextButton(
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                                      minimumSize: Size.zero,
                                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    ),
                                                    onPressed: () {
                                                      if (currentConfig.buttonAction != null) {
                                                        currentConfig.buttonAction!(context);
                                                      }
                                                    },
                                                    child: Text(
                                                      currentConfig.buttonLabel,
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        color: currentConfig.buttonColor,
                                                        fontFamily: AppTheme.fontFamily,
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const Divider(height: 0)
                                        ],
                                      ),
                                    ],
                                ),

                                // 4. พื้นที่เนื้อหาที่มี Navigator ฝังอยู่
                                Flexible(
                                  // โหมดกล่อง: ยอมหดได้ แล้วบังคับความสูงด้วย SizedBox ข้างล่าง
                                  fit: measurable ? FlexFit.loose : currentConfig.fit,
                                  child: SizedBox(
                                    // ยังไม่ได้วัด (เฟรมแรก) ก็ปล่อยให้เต็มไปก่อน
                                    // แล้ว AnimatedContainer จะไล่ความสูงลงมาให้เอง
                                    height: measurable ? contentHeight : null,
                                    child: ClipRRect(
                                      child: Navigator(
                                        key: nestedNavKey,
                                        onGenerateRoute: (settings) {
                                          return MaterialPageRoute(
                                            builder: (navContext) {
                                              // วัดตรงลูกของ scroll view เพราะตรงนั้นความสูงยังไม่ถูกจำกัด
                                              // จึงได้ความสูงตามธรรมชาติของเนื้อหาจริงๆ
                                              final content = measurable
                                                  ? _MeasureHeight(
                                                      onHeight: (h) {
                                                        if (contentHeight != null &&
                                                            (contentHeight! - h).abs() <= 0.5) {
                                                          return;
                                                        }
                                                        setState(() => contentHeight = h);
                                                      },
                                                      child: builder(navContext),
                                                    )
                                                  : builder(navContext);

                                              return currentConfig.scroll
                                                  ? SingleChildScrollView(
                                                      keyboardDismissBehavior:
                                                          ScrollViewKeyboardDismissBehavior.onDrag,
                                                      physics: const AlwaysScrollableScrollPhysics(),
                                                      child: content,
                                                    )
                                                  : content;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                  ),
            );
          },
        );
      },
    );
  }
}

/// วัดความสูงจริงของลูก แล้วรายงานกลับหลังวางเลย์เอาต์เสร็จ
///
/// ใช้กับ popup แบบ wizard เท่านั้น — ดูเหตุผลที่ `contentHeight` ใน
/// `DynamicPushPopup.showPopup`
class _MeasureHeight extends SingleChildRenderObjectWidget {
  final ValueChanged<double> onHeight;

  const _MeasureHeight({required this.onHeight, required Widget super.child});

  @override
  _RenderMeasureHeight createRenderObject(BuildContext context) =>
      _RenderMeasureHeight(onHeight);

  @override
  void updateRenderObject(BuildContext context, _RenderMeasureHeight renderObject) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderMeasureHeight extends RenderProxyBox {
  _RenderMeasureHeight(this.onHeight);

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (_reported != null && (_reported! - height).abs() <= 0.5) return;
    _reported = height;
    // เรียก setState ระหว่าง layout ไม่ได้ ต้องรอให้เฟรมนี้จบก่อน
    WidgetsBinding.instance.addPostFrameCallback((_) => onHeight(height));
  }
}
