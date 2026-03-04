import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:attendance_system/shared/theme/app_colors.dart'; // ใส่ path ของคุณ
// import 'dynamic_popup_config.dart'; // ระบุ path ไฟล์ config ที่เพิ่งสร้าง

class DynamicPushPopup {
  final PopupConfig initialConfig;
  final Widget Function(BuildContext context) builder;

  DynamicPushPopup({
    required this.initialConfig,
    required this.builder,
  });

  void showPopup(BuildContext context) {
    final theme = Theme.of(context);
    final GlobalKey<NavigatorState> nestedNavKey = GlobalKey<NavigatorState>();

    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 200),
    );

    // เก็บสถานะ Config ปัจจุบัน
    PopupConfig currentConfig = initialConfig;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionAnimationController: controller,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Theme(
              data: theme,
              // หุ้มด้วย Provider เพื่อให้หน้าย่อยสั่งงานได้
              child: PopupProvider(
                config: currentConfig,
                setConfig: (PopupConfig newConfig) {
                  setState(() {
                    currentConfig = newConfig; // รีเฟรชกรอบ Popup ใหม่
                  });
                },
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350), // 👈 ตั้งความเร็วตอนเลื่อนความสูง
                    curve: Curves.easeOutCubic,
                    constraints: BoxConstraints(
                      minHeight: currentConfig.minHeight,
                      maxHeight: currentConfig.maxHeight == double.infinity
                          ? MediaQuery.of(context).size.height * 0.9
                          : currentConfig.maxHeight,
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 30,
                              spreadRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          bottom: currentConfig.safeArea,
                          left: currentConfig.safeArea,
                          right: currentConfig.safeArea,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.88,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 15,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                                  child: Column(
                                    spacing: 15,
                                    children: [
                                      Container(
                                        color: const Color(0xFFA6A6A6),
                                        width: 70,
                                        height: 3,
                                      ),
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
                                  )
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
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}