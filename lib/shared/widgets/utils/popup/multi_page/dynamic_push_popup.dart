import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import 'package:attendance_system/shared/widgets/utils/popup/popup_surface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                                                  style: const TextStyle(
                                                    decoration: TextDecoration.none,
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                    fontFamily: 'Inter',
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
                                                        fontFamily: 'Inter',
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
                                  fit: currentConfig.fit,
                                  child: ClipRRect(
                                    child: Navigator(
                                      key: nestedNavKey,
                                      onGenerateRoute: (settings) {
                                        return MaterialPageRoute(
                                          builder: (navContext) => currentConfig.scroll
                                              ? SingleChildScrollView(
                                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                            physics: const AlwaysScrollableScrollPhysics(),
                                            child: builder(navContext),
                                          )
                                              : builder(navContext),
                                        );
                                      },
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